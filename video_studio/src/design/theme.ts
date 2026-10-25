// LabGuide video design system: colour, type and layout tokens.
// Palette derives from the app's brand green (#1B5E50 / #1F5A4C, schematic
// callouts and app primary) on a deep "lab at night" ink background.

export type Format = 'vertical' | 'horizontal';
export type Lang = 'en' | 'ru' | 'uz';

export const color = {
  bg0: '#05110E',
  bg1: '#0A1E19',
  bg2: '#0F2A23',
  panel: 'rgba(255,255,255,0.045)',
  panelStrong: 'rgba(255,255,255,0.08)',
  line: 'rgba(190,235,215,0.16)',
  grid: 'rgba(190,235,215,0.07)',
  ink: '#EEF6F2',
  inkDim: '#A9C2B8',
  inkFaint: '#6F8C81',
  brand: '#1B5E50',
  brandBright: '#2E8C73',
  mint: '#79E0B4',
  mintSoft: 'rgba(121,224,180,0.18)',
  amber: '#F4B740',
  amberSoft: 'rgba(244,183,64,0.18)',
  coral: '#FF8A76',
  coralSoft: 'rgba(255,138,118,0.18)',
  beam: '#8FE3FF',
  white: '#FFFFFF',
};

export const font = {
  sans: 'Inter, system-ui, sans-serif',
  serif: '"Instrument Serif", Georgia, serif',
};

export type Metrics = {
  w: number;
  h: number;
  /** Safe side margin. */
  gutter: number;
  /** Top of the content area (below platform UI). */
  top: number;
  /** Bottom of the content area (subtitles live below it). */
  contentBottom: number;
  /** Subtitle box: bottom edge y and max width. */
  subBottom: number;
  subMaxW: number;
  subSize: number;
  display: number;
  h1: number;
  h2: number;
  body: number;
  small: number;
  kicker: number;
};

export function metrics(format: Format): Metrics {
  if (format === 'vertical') {
    return {
      w: 1080,
      h: 1920,
      gutter: 84,
      top: 150,
      contentBottom: 1420,
      // Above the bottom ~15% that Shorts/Reels/TikTok cover with their UI.
      subBottom: 1640,
      subMaxW: 940,
      subSize: 48,
      display: 220,
      h1: 78,
      h2: 58,
      body: 40,
      small: 32,
      kicker: 30,
    };
  }
  return {
    w: 1920,
    h: 1080,
    gutter: 120,
    top: 96,
    contentBottom: 900,
    subBottom: 1028,
    subMaxW: 1480,
    subSize: 44,
    display: 200,
    h1: 70,
    h2: 50,
    body: 34,
    small: 27,
    kicker: 26,
  };
}

/** Tabular numerals for every animated number. */
export const tabular = {fontVariantNumeric: 'tabular-nums' as const};
