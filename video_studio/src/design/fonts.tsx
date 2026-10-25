// Fonts are loaded from the repository's own OFL files (assets/fonts, copied
// to public/fonts by scripts/prepare.mjs). No font CDN, no network.
import {useEffect, useState} from 'react';
import {continueRender, delayRender, staticFile} from 'remotion';

const faces: {family: string; file: string; weight: string}[] = [
  {family: 'Inter', file: 'fonts/Inter-400.ttf', weight: '400'},
  {family: 'Inter', file: 'fonts/Inter-500.ttf', weight: '500'},
  {family: 'Inter', file: 'fonts/Inter-600.ttf', weight: '600'},
  {family: 'Inter', file: 'fonts/Inter-700.ttf', weight: '700'},
  {family: 'Instrument Serif', file: 'fonts/InstrumentSerif-Regular.ttf', weight: '400'},
];

let loading: Promise<void> | null = null;

function loadAll(): Promise<void> {
  if (!loading) {
    loading = Promise.all(
      faces.map(async (f) => {
        const face = new FontFace(f.family, `url(${staticFile(f.file)})`, {
          weight: f.weight,
        });
        await face.load();
        (document.fonts as unknown as {add: (f: FontFace) => void}).add(face);
      }),
    ).then(() => undefined);
  }
  return loading;
}

/** Blocks rendering until all fonts are ready (no fallback-font frames). */
export function useFonts(): boolean {
  const [handle] = useState(() => delayRender('Loading local fonts'));
  const [ready, setReady] = useState(false);
  useEffect(() => {
    loadAll()
      .then(() => {
        setReady(true);
        continueRender(handle);
      })
      .catch((e) => {
        console.error(e);
        continueRender(handle);
      });
  }, [handle]);
  return ready;
}
