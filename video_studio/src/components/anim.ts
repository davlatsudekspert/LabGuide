// Small animation helpers on top of Remotion's interpolate/spring.
import {Easing, interpolate, spring} from 'remotion';

export const clamp = {extrapolateLeft: 'clamp', extrapolateRight: 'clamp'} as const;

/** 0→1 over [start, start+dur] frames with ease-out. */
export function ease(frame: number, start: number, dur: number): number {
  return interpolate(frame, [start, start + dur], [0, 1], {
    ...clamp,
    easing: Easing.bezier(0.22, 1, 0.36, 1),
  });
}

/** 0→1 ease-in-out. */
export function easeIO(frame: number, start: number, dur: number): number {
  return interpolate(frame, [start, start + dur], [0, 1], {
    ...clamp,
    easing: Easing.bezier(0.65, 0, 0.35, 1),
  });
}

/** Critically damped spring 0→1 starting at `start`. */
export function pop(frame: number, fps: number, start: number, stiffness = 140): number {
  return spring({
    frame: frame - start,
    fps,
    config: {damping: 18, stiffness, mass: 0.9},
  });
}

/** Opacity + rise for text entering. */
export function rise(t: number, px = 28) {
  return {opacity: t, transform: `translateY(${(1 - t) * px}px)`};
}

export function lerp(a: number, b: number, t: number) {
  return a + (b - a) * t;
}
