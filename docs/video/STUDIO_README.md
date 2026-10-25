# LabGuide video studiyasi (Remotion + FFmpeg)

Bu hujjat — `video_studio/` loyihasi bilan yangi video qanday qilinishi haqida. Birinchi (flagman) video:
**Kalibrlash** — `docs/video/calibration/`. Keyingi videolar (masalan, leykoformula) xuddi shu karkasni
ishlatadi: faqat storyboard JSON, til paketlari va kerak bo‘lsa yangi qatlam (layer) yoziladi.

Holat: hamma videolar **EXPERT_REVIEW_PENDING** — mutaxassis va ona tili egasi ko‘rmaguncha "tasdiqlangan"
deb belgilanmaydi.

## 1. Tuzilma

```
docs/video/<id>/                 ← REVIEW qilinadigan manba (bir joyda)
  storyboard.json                  sahnalar: id, layer, narration line id lari, minSec, props; data (namunaviy raqamlar)
  lines.en.json / .ru.json / .uz.json   narration qatorlari (en = ovoz; ru/uz = subtitr) + `ui` (ekrandagi matnlar)
  SCRIPT.md, MATH_APPENDIX.md, OUTPUTS.md   ← `npm run docs` YARATADI (qo‘lda tahrir qilinmaydi)
  CLAIMS_AND_EVIDENCE.md           har da’vo → kod/test/hujjat dalili + epistemik jadval (qo‘lda)
video_studio/
  src/design/        theme.ts (rang, shrift o‘lchami, xavfsiz chegaralar 9:16 va 16:9), fonts.tsx (repo’dagi Inter / Instrument Serif)
  src/lib/           regression.js, timing.js, subtitles.js, text.js — Remotion VA Node skriptlari bir xil kodni ishlatadi
  src/components/    Background, SceneHeader, Badge, Pill, SubtitleTrack, PhoneFrame, SchematicStage, OpticalBench/Cuvette, CalibrationChart/ResidualPanel
  src/framework/     StoryboardVideo (umumiy sahna grafi), types
  src/videos/<id>/   index.tsx (VideoDef + thumbnail), layers.tsx (shu videoning qatlamlari)
  flutter_walk/      ilovaning HAQIQIY ekranlarini olish testi (Flutter checkout’dan tashqarida turadi)
  scripts/           prepare, render, still, voice, docs (+ lib.mjs)
  public/frames/, public/fonts/, public/brand/, public/audio/**/*.wav, out/   ← gitignore (qayta yaratiladi)
```

## 2. Tillar qanday bo‘lishadi

* **Bitta sahna grafi.** Kompozitsiyalar: `<id>-vertical` (1080×1920) va `<id>-horizontal` (1920×1080), shuningdek
  `<id>-thumb` (1280×720) va `<id>-cover` (1080×1920). Sahna tuzilmasi til bo‘yicha qayta qurilmaydi —
  til faqat **props**: `lang` (matn paketi), `appFrames` (shu tildagi ilova kadrlari), `timing`.
* **Vaqt manbai — inglizcha diktor manifesti** (egasi qarori, 2026-10-25): barcha nashrlar bitta **inglizcha**
  ovoz yo‘lagini ishlatadi; rus va o‘zbek nashrlari faqat subtitr (kadrga yozilgan + `.srt/.vtt`) va ekrandagi
  matn bilan farq qiladi. Rus/o‘zbek tarjimalari inglizcha qatorlar oynasiga sig‘ishi kerak (≤ 2 qator,
  vertikalda 48 px); audio tezlashtirilmaydi — kerak bo‘lsa tarjima qisqartiriladi.
* Ovoz yo‘q bo‘lsa: `timing.js → placeholderTiming` inglizcha matndan taxminiy davomiylik hisoblaydi (sukut).
* Nega har til alohida Remotion pass? Ekrandagi matn va ilova ekranlari (ilova tili!) tilga bog‘liq — "matnsiz
  asos + overlay" ham xuddi shuncha Chromium kadri chizadi, tejash bermaydi. Tejash shunda: sahnalar bir marta
  yozilgan, kadrlar diskka yozilmaydi (to‘g‘ridan-to‘g‘ri ffmpeg ga), ovoz bir marta sintez + bir marta loudnorm,
  so‘ng 6 nashrga faqat AAC qilib qo‘shiladi; subtitr fayllari ikkala format uchun bitta.

## 3. Yangi video qo‘shish (masalan, `leukocyte_differential`)

1. **Storyboard.** `docs/video/<id>/storyboard.json`: `scenes[]` (`id`, `layer`, `lines`, `minSec`, `props`),
   `timing` (lead/tail/gap, `cps`), `data` (agar grafik bo‘lsa — namunaviy, belgilangan). Har sahnada kamida
   bitta narration qatori bo‘lsin (sahna chegaralari shu qatorlardan hisoblanadi).
2. **Til paketlari.** `lines.en.json` (ovoz matni; `spoken` — TTS uchun faqat talaffuz yozuvi), `lines.ru.json`,
   `lines.uz.json` (subtitr) + `ui` kalitlari. O‘zbekcha lotin: o‘ g‘ uchun `‘` (U+2018), tutuq belgisi `’`
   (U+2019); atamalar ARB va `docs/L10N_TERMINOLOGY_DECISIONS.md` bo‘yicha.
3. **Qatlamlar.** `src/videos/<id>/layers.tsx` — mavjud komponentlardan yig‘ing (PhoneFrame, SchematicStage,
   CalibrationChart, SceneHeader, Badge…). `index.tsx` da `VideoDef` (`compute`, `vars`, `Thumb`,
   `continuous`), `src/Root.tsx` dagi `videos` ro‘yxatiga va `scripts/lib.mjs → VIDEO_MATH` ga qo‘shing.
4. **Ilova kadrlari.** `video_studio/flutter_walk/<id>_walk_test.dart` (kalibrlash testi namuna): faqat haqiqiy
   ekran, uchinchi tomon brend nomi kadrga tushmasin, `marks` bilan belgilanadigan joylar o‘lchanadi.
   ```sh
   cd /home/user/wt-audit     # Flutter checkout (faqat o‘qish uchun; test fayli tashqarida)
   flock /tmp/flutter_test.lock /root/sdk/flutter/bin/flutter test \
     /home/user/wt-video/video_studio/flutter_walk/<id>_walk_test.dart --update-goldens
   ```
   Hech qachon parallel emas (lock). Natija: `video_studio/public/frames/<lang>/<id>/`.
5. **Tekshiruv kadrlari (render qilmasdan).**
   `npm run still -- --id <id> --lang uz --format horizontal --scenes all --at 0.5` → `out/stills/`.
   Har sahnani to‘liq o‘lchamda ko‘ring (matn sig‘ishi, qirqilish, subtitr ostida qolish).
6. **Ovoz (inglizcha).**
   ```sh
   python3 -m venv /tmp/kv && /tmp/kv/bin/pip install kokoro-onnx soundfile   # ~184 MB, ishdan keyin o‘chiring
   # model: kokoro-v1.0.int8.onnx (92 MB) + voices-v1.0.bin (28 MB), github.com/thewh1teagle/kokoro-onnx releases
   npm run voice -- --id <id> --python /tmp/kv/bin/python --model …/kokoro-v1.0.int8.onnx --voices …/voices-v1.0.bin --voice af_heart
   ```
   `tool/tts/synth.py` (o‘zgartirmasdan) har qatorni sintez qiladi; skript qatorlarni sahna qoidalari bo‘yicha
   joylaydi, ffmpeg bilan aralashtiradi va **ikki o‘tishli loudnorm** (−16 LUFS; WAV da true peak −2 dBTP, AAC dan keyin MP4 da ≤ −1,5 dBTP — o‘lchangan: −2,0) qiladi →
   `public/audio/en/<id>.wav` + `<id>.timing.json`. Ovoz yo‘q bo‘lsa bu qadam tashlab ketiladi — render sukutda.
   Ovoz haqida: "English synthetic narration (Kokoro), listening review pending" — "tabiiy/professional" demang.
7. **Render.** `npm run render -- --id <id> --lang all --format all` (yoki `--lang en --format vertical`;
   tez tekshiruv: `--frames 0-149`). H.264 High, yuv420p, 30 fps, +faststart, ovoz bo‘lsa AAC 48 kHz.
   Chiqish: `out/<id>/<lang>/<id>_<lang>_<format>.mp4`, `<id>_<lang>.srt/.vtt`, thumbnail va cover JPG.
   Ovoz vaqti o‘zgarmay faqat WAV yangilansa (masalan, loudness): `npm run remux -- --id <id>` — video
   qayta render qilinmaydi (stream copy), faqat audio almashadi.
8. **Hujjatlar.** `npm run docs -- --id <id>` → SCRIPT.md, MATH_APPENDIX.md, OUTPUTS.md (ffprobe + sha256).
   CLAIMS_AND_EVIDENCE.md ni qo‘lda yozing: ekrandagi har da’vo → kod/test/hujjat.
9. **Paket.** MP4 + SRT/VTT + JPG lar `out/` da qoladi; hech qayerga yuklanmaydi. Tavsifga: "Narration generated
   with AI text-to-speech (Kokoro-82M, Apache-2.0)." (Piper ljspeech ishlatilsa: ovoz ma’lumoti public domain).

## 4. Render vaqti va disk

* 4 yadroli mashina, boshqa agentlar Flutter testlarini yurgizayotgan paytda: **~5,5 kadr/s** (concurrency 3) →
  ~92 s lik video (2 748 kadr) ≈ 8–9 daqiqa; 6 nashr ≈ 55 daqiqa. Still — bitta kadr 2–4 s.
* **Muhim:** Chromium’ga `gl: 'swangle'` bermang — bu mashinada 7× sekin (0,8 kadr/s). Standart (null) ishlatiladi.
* Kadrlar diskka yozilmaydi (JPEG buferlar → ffmpeg stdin). `node_modules` ≈ 300 MB (musl binarlari o‘chirilgan;
  `npm install` qayta tiklasa — `@remotion/compositor-linux-x64-musl` va `@rspack/binding-linux-x64-musl` ni
  o‘chirib tashlash mumkin). Har MP4 ≈ 20–40 MB. Remotion o‘z Chromium’ini yuklamaydi:
  `/opt/pw-browsers/chromium_headless_shell-1194/…/headless_shell` (`REMOTION_BROWSER` bilan almashtiriladi).
* Sparse checkout: `video_studio` va `tool/tts` ikkalasi ham ro‘yxatda bo‘lsin (`git sparse-checkout add video_studio tool/tts`) — aks holda `sparse-checkout add` boshqa papkani ishchi daraxtdan olib tashlaydi.
* Render oldidan `df -h /home`; skript 400 MB dan kam joy bo‘lsa to‘xtaydi.

## 5. Litsenziyalar

* **Remotion** — "Remotion License": jismoniy shaxslar, notijorat tashkilotlar va **3 tagacha xodimli** tijorat
  tashkilotlari uchun bepul (tijoriy video ham); kattaroq tijorat tashkilotiga **Company License** kerak
  (`node_modules/remotion/LICENSE.md`, remotion.pro/license). **Egasi o‘z kompaniyasi hajmini tekshirishi shart.**
* Shriftlar: Inter, Instrument Serif — OFL (`assets/fonts/*-OFL.txt`). Sxemalar — LabGuide’ning o‘z ishi
  (`docs/SCHEMATICS_PROVENANCE.md`). Logotip — egasining logosi (`assets/images/logo_mark_large.png`).
* Ovoz: Kokoro-82M (Apache-2.0), `docs/video/tts/VOICE_DECISION.md`. Musiqa yo‘q.
* Uchinchi tomon logotipi, brend nomi, stok video yoki suv belgisi ishlatilmaydi.
