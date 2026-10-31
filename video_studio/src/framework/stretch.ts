// What a scene looks like when the language edition (Uzbek) makes it LONGER than the English original.
//
// Facts about the layers (checked per layer file, see docs/video/voice_uz/RETIME_DESIGN.md):
//  * nearly every reveal is keyed to a narration cue (scene.cues[i].start / .end), so with the re-timed
//    timeline the reveals simply follow the Uzbek lines; short fixed animations (ease 10-14 frames, pop) keep
//    their English pace, i.e. NOTHING is time-stretched into slow motion, and the hook (first 3 s, cue 0 at 0.25 s)
//    is identical to the English edition;
//  * a few animations span the whole scene or a line (drawn curves, zoom drifts); they follow the new length;
//  * the end of a long scene shows the final composed state: that is the "hold" the idle motion keeps alive.
//
// Per layer type (and per scene via storyboard `props.stretch`) two knobs:
//   mode  'cue'  (default) the layer gets the NEW scene (new cues, new length): reveals follow the Uzbek voice.
//         'hold' the layer runs on the ORIGINAL English scene (original cues and length) at the original pace and
//                its last frame is held for the extra time (Remotion <Freeze>). For ambient scenes whose
//                animation is not tied to the words.
//   idle  amplitude of a slow "breathing" zoom (fraction, 0 = off) applied ONLY during the extra seconds, starting
//         and ending at scale 1.0 (so there is no jump into the next scene's cross-fade). Not used for layers listed
//         in `continuous` (they hard-cut into the next scene) and not for phone screens (their zoom drift already
//         follows the window length).
import type {LaidScene} from './types';

export type StretchMode = 'cue' | 'hold';
export type StretchPolicy = {mode: StretchMode; idle: number};

export const DEFAULT_POLICY: StretchPolicy = {mode: 'cue', idle: 0.009};

/** Defaults per layer type; any layer not listed uses DEFAULT_POLICY. */
export const LAYER_POLICY: Record<string, Partial<StretchPolicy>> = {
  phone: {idle: 0},
  hook: {mode: 'cue'},
  cta: {mode: 'cue'},
};

export function policyFor(scene: LaidScene, continuous: boolean): StretchPolicy {
  const p = {...DEFAULT_POLICY, ...(LAYER_POLICY[scene.layer] ?? {}), ...((scene.props?.stretch as Partial<StretchPolicy>) ?? {})};
  if (continuous) p.idle = 0;
  return p;
}

/** Scale of the idle breathing at scene frame `frame`; 1 outside the extra seconds. */
export function idleScale(frame: number, baseFrames: number, durFrames: number, fps: number, amp: number): number {
  const extra = durFrames - baseFrames;
  if (amp <= 0 || extra < fps * 0.6 || frame <= baseFrames) return 1;
  const cycles = Math.max(1, Math.round(extra / (fps * 8)));
  const p = Math.min(1, (frame - baseFrames) / extra);
  const s = Math.sin(Math.PI * p * cycles);
  return 1 + amp * s * s;
}
