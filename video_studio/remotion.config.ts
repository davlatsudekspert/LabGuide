// Remotion CLI config (used by `npx remotion studio` / `npx remotion still`).
// Renders for delivery go through scripts/render.mjs (system ffmpeg).
import {Config} from '@remotion/cli/config';

// Preinstalled Chromium headless shell: Remotion must not download its own.
Config.setBrowserExecutable(
  process.env.REMOTION_BROWSER ??
    '/opt/pw-browsers/chromium_headless_shell-1194/chrome-linux/headless_shell',
);
Config.setVideoImageFormat('jpeg');
Config.setConcurrency(3);
