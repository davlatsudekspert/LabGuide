# LabGuide Instagram reel (labs) — trilingual

One vertical reel, 1080x1920, 39.2 s, 30 fps, h264 + silent AAC track. NO narration, NO music (add music inside Instagram).
Burned-in captions: Uzbek (top, largest), Russian, English stacked in the lower third, inside Instagram safe margins
(plate x 120–960, bottom 340 px free; text sizes uz 52 / ru 42 / en 36 px; end card 112/72/60). Hook is a question, not a claim.

**All uz and ru text = NEEDS_NATIVE_REVIEW** (en also by the owner/editor). Never reviewed by a native speaker.

## Timeline
0–3.8 hook (3D phone with the real home screen, drawn tally sheets, app icon) · 3.8–11.8 Leykoformula · 11.8–19.4 Kalibrlash ·
19.4–26.6 Sitologiya · 26.6–34.8 Bilim va malakani baholash (Test) · 34.8–39.2 end card: logo, LabGuide, "Tez kunda / Скоро / Coming soon", "uz · ru · en".
No store badge or store wording anywhere.

## Source of truth
* `reel.json` here: cues (uz/ru/en), sections, shots with highlight rectangles/taps. The same cues produce the burned captions and `subs/*.srt|vtt`.
* Visuals: `video_studio/src/videos/reel_labs/Reel.tsx` (+ `hero3d.tsx`, copy of the overview video's 3D pieces, because that file is still untracked in the overview worktree), entry `video_studio/src/reel_entry.tsx`, renderer `video_studio/scripts/render_reel.mjs`.
* Render: `node scripts/render_reel.mjs --video --concurrency 2` (frames via Remotion, system ffmpeg). Outputs (gitignored):
  `video_studio/out/reel_labs/trilingual/reel_labs_uz-ru-en_vertical.mp4`, `..._cover_1080x1920.jpg`, `reel_labs_{uz,ru,en}.srt|vtt`. Copies of the subtitle files: `docs/video/reel_labs/subs/`.

## App frames (all REAL, Uzbek UI, nothing drawn or edited)
Reused from earlier videos: leukocyte (d_lab, d_count0, d_tap1–5, d_result), calibration (cal_path, cal_record, cal_saved, cal_log), overview (home_lab, assessment hub, exam_setup, exam_run, exam_result).
**Newly captured** for this reel (no cytology frame existed): `video_studio/flutter_walk/reel_walk_test.dart` (same widget-test method as `overview_walk_test.dart`, run in /home/user/wt-audit app build, FRAMES_OUT env added to `walk_kit.dart`): `cy_home`, `cy_cells`, `cy_cell` in uz (ru/en were captured too but not used; the reel shows the uz UI only).
Frame gaps: none. Not shown: the app's ru/en UI (captions are trilingual, the UI is uz).

## Known notes
* Calibration is called "Kalibrlash" in the Uzbek UI; captions use the app's word.
* Test section names in captions are the owner's: "Bilim va malakani baholash" / «Оценка знаний и навыков» / "Knowledge and skills assessment" (the app's own ru/en titles differ slightly).
* The assessment hub frame has a small app line under its title (specialty text); it is the app's own text.
* Banned wording: grep over captions, SRT/VTT, sources and docs is clean.
