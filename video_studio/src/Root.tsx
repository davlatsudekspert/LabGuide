// Composition registry. Per video: <id>-vertical, <id>-horizontal (the same
// scene graph), <id>-thumb (1280x720) and <id>-cover (1080x1920) stills.
// Language, timing (voice) and app-frame metadata are input props.
import React from 'react';
import {Composition, Still} from 'remotion';
import {buildContext, StoryboardVideo} from './framework/StoryboardVideo';
import type {VideoDef, VideoProps} from './framework/types';
import {useFonts} from './design/fonts';
import {calibrationVideo} from './videos/calibration';
import {leukocyteVideo} from './videos/leukocyte';

export const videos: VideoDef[] = [calibrationVideo, leukocyteVideo];

const defaults: VideoProps = {lang: 'en', timing: null, appFrames: null, subtitles: true};

const ThumbHost: React.FC<{def: VideoDef; kind: 'landscape' | 'cover'} & VideoProps> = ({def, kind, ...props}) => {
  useFonts();
  const {ctx} = buildContext(def, props, kind === 'landscape' ? 'horizontal' : 'vertical');
  const T = def.Thumb;
  return <T ctx={ctx} kind={kind} />;
};

export const Root: React.FC = () => (
  <>
    {videos.map((def) => (
      <React.Fragment key={def.id}>
        {(['vertical', 'horizontal'] as const).map((format) => (
          <Composition
            key={format}
            id={`${def.id}-${format}`}
            component={(p: VideoProps) => <StoryboardVideo def={def} format={format} {...p} />}
            width={def.storyboard.formats[format].width}
            height={def.storyboard.formats[format].height}
            fps={def.storyboard.fps}
            durationInFrames={300}
            defaultProps={defaults}
            calculateMetadata={({props}) => ({
              durationInFrames: buildContext(def, props, format).layout.durationInFrames,
            })}
          />
        ))}
        <Still
          id={`${def.id}-thumb`}
          component={(p: VideoProps) => <ThumbHost def={def} kind="landscape" {...p} />}
          width={1280}
          height={720}
          defaultProps={defaults}
        />
        <Still
          id={`${def.id}-cover`}
          component={(p: VideoProps) => <ThumbHost def={def} kind="cover" {...p} />}
          width={1080}
          height={1920}
          defaultProps={defaults}
        />
      </React.Fragment>
    ))}
  </>
);
