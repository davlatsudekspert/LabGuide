// Entry for the Instagram reel (trilingual burned-in captions). Separate from
// Root.tsx on purpose: it bundles only what the reel needs.
import React from 'react';
import {Composition, registerRoot} from 'remotion';
import {Reel, REEL_FRAMES} from './videos/reel_labs/Reel';

const Root: React.FC = () => (
  <Composition id="reel-labs" component={Reel} width={1080} height={1920} fps={30} durationInFrames={REEL_FRAMES} />
);

registerRoot(Root);
