# Ishlaydigan namunaviy animatsiyalar (2 ta dars) — 2026-10-25

**Holat:** EXPERT_REVIEW_PENDING. Bu — ikki dars rejasining (01 GC-MS, 04 real vaqt PCR) **animatsion qismi
namunasi**: ovozsiz, subtitrli MP4. Diktor ovozi yo‘q, musiqa yo‘q; to‘liq 3–6 daqiqalik dars emas.

## Nima qilindi

| | |
|---|---|
| Asos | Ilovaning ORIGINAL sxemalari `tool/illustrations/schematic/mass_spec_gc.svg` va `real_time_pcr.svg` — o‘zgartirilmasdan pleyerga qo‘yiladi; raqamli belgilar (`<g id="callouts">`) o‘sha SVG dan |
| Animatsiya | `tool/video/lessons/anim_gc_ms.js`, `anim_real_time_pcr.js` — sxemaning o‘z koordinatalar tizimida (gen.py sahnasi) ustki qatlam; JS, har kadr `window.renderAt(t)` bilan deterministik (real soat yo‘q) |
| Pleyer | `tool/video/lessons/player.html` — subtitr kartochkasi, 6 bosqich chizig‘i, sxema “kamerasi” (viewBox), qism chipi (nomi uz/ru/en + “manbali” yoki “umumiy tamoyil” yorlig‘i), pastki natija paneli, doimiy yorliqlar |
| Ma’lumot | `tool/video/lessons/sample_gc_ms.json`, `sample_real_time_pcr.json` — sahnalar, kamera, subtitrlar uz/ru/en, har sahna uchun epistemik ID lar (dars faylidagi jadvalga mos) |
| Render | `tool/video/lessons/render_sample.cjs` — Playwright Chromium (oldindan o‘rnatilgan, `NODE_PATH=$(npm root -g)`), kadrlar PNG sifatida to‘g‘ridan-to‘g‘ri ffmpeg ga uzatiladi (diskka kadr yozilmaydi): H.264 (libx264, CRF 26, yuv420p), 24 fps, `-an` (ovozsiz), `+faststart`; SRT/VTT o‘sha vaqt jadvalidan |
| Hisobot | `tool/video/lessons/report_samples.py` — ffprobe va sha256 (quyidagi jadval) |
| Chiqish | `build/lesson_samples/` (gitignore; repoga faqat matn/skript kiritilgan) |

### Format tanlovi: 720×1280 (tik)

- `tool/video/compose.py` dagi mavjud video qo‘llanmalar seriyasi bilan bir xil (720×1280, 24 fps, kadrga yozilgan
  subtitr, alohida SRT/VTT, kirish va yakun kartochkalari, “ovozsiz” halol yorlig‘i).
- LabGuide — telefon ilovasi; darslar asosan telefonda tik holatda ko‘riladi deb taxmin qilinadi.
- Sxema 3:2 bo‘lgani uchun tik kadrda kichikroq ko‘rinadi — buni “kamera” yaqinlashuvi (viewBox) va pastdagi
  kattalashtirilgan natija paneli (xromatogramma/spektr, kuchayish egri chiziqlari) qoplaydi; bo‘sh joy esa
  subtitr, bosqichlar chizig‘i va qism nomi uchun ishlatiladi.
- Kamchiligi: auditoriyada proyektor uchun 1280×720 qulayroq bo‘lishi mumkin — pleyerda o‘lcham bir joyda
  (`render_sample.cjs` `W, H` va `player.html` CSS) va kerak bo‘lsa alohida varianti qilinadi.

### Ekrandagi halol yorliqlar (har kadrda)

- “Sxematik animatsiya — aniq model emas · Ovozsiz namuna (diktorsiz)” (ru/en tarjimasi bilan);
- “Mutaxassis ko‘rigi kutilmoqda (EXPERT_REVIEW_PENDING)”;
- pastki panel sarlavhasi: “… — namuna chizma, haqiqiy natija emas”; o‘qlarda raqam yo‘q;
- qism chipida — manba holati: `manbali` (catalog manbasi) yoki `umumiy tamoyil` (darslik/NEEDS_EXPERT);
- subtitrlar “Manbaga ko‘ra: …” yoki “Umumiy tamoyil: …” bilan boshlanadi (dars faylidagi qoida bilan bir xil).

## GC-MS namunasi (`gc_ms_*`, 96 s) — dars `01_gc_ms.md`

| Vaqt, s | Bosqich | Ekranda / animatsiya | Bayonotlar (01-dars jadvali) |
|---|---|---|---|
| 0–3,5 | — | Kirish kartochkasi (sarlavha, yorliqlar) | — |
| 3,5–10,5 | 1 Ko‘rinish | To‘liq sxema, 1–10-belgilar | L1 |
| 10,5–20,5 | 2 Qismlar | Kamera chapga; 1–5-belgilar navbat bilan halqa va chip bilan | C1–C5 |
| 20,5–30,5 | 2 Qismlar | Kamera o‘ngga; 6–10-belgilar | C6–C10 |
| 30,5–39,5 | 3 Namuna | Shprisdagi suyuqlik kamayadi, tomchi injektorga tushadi, bug‘ bulutchasi kolonka kirishiga; tashuvchi gaz oqimi (shtrixli chiziq) | L3, C1–C3 |
| 39,5–52,5 | 4 Jarayon | Uch rangli zona kolonka spirali bo‘ylab turli tezlikda yuradi va turli vaqtda chiqadi; pastda xromatogramma cho‘qqilari shu paytda chiziladi | C4, PR |
| 52,5–61,5 | 4 Jarayon | Neytral molekula uzatish liniyasidan ion manbaiga; elektronlar (e−) va “+” zaryadli bo‘laklar | C5, C6 |
| 61,5–73,5 | 5 Signal | Kvadrupol: har lahzada bitta “o‘tayotgan m/z” rangi to‘g‘ri o‘tadi, qolganlari tebranib sterjenlarga uriladi va so‘nadi | L2, C7 |
| 73,5–80,5 | 5 Signal | Detektorda chaqnash, signal monitor tomon | C8 |
| 80,5–92,5 | 6 Natija | Xromatogramma kichrayadi, tanlangan cho‘qqi belgilanadi, mass-spektr chiziqchalari, so‘ng kutubxona/standart spektri (teskari, “umumiy tamoyil”) | L2, RS, C10 |
| 92,5–96 | — | Yakun kartochkasi | — |

Ataylab ko‘rsatilmaydi: harorat dasturi, gaz oqimi, vakuum darajasi, ionlash energiyasi, m/z qiymatlari, vaqt
o‘qidagi raqamlar; vakuum nasosi (9) faqat nomi bilan (NEEDS_EXPERT).

## Real vaqt PCR namunasi (`real_time_pcr_*`, 77 s) — dars `04_real_time_pcr.md`

| Vaqt, s | Bosqich | Ekranda / animatsiya | Bayonotlar (04-dars jadvali) |
|---|---|---|---|
| 0–3,5 | — | Kirish kartochkasi | — |
| 3,5–10,5 | 1 Ko‘rinish | To‘liq sxema, 1–7-belgilar | L1 |
| 10,5–22,5 | 2 Qismlar | 1–7-belgilar navbat bilan halqa va chip bilan | C1–C7 |
| 22,5–31,5 | 3 Namuna | Probirkalar qatori yoy bo‘ylab termoblokka “ko‘chadi”, blokdagi 8 uyacha yonadi | L3, L2, C1, C3 |
| 31,5–47,5 | 4 Jarayon | Blok rangi qizdirish/sovutish/sintez bo‘yicha almashadi; pastda raqamsiz sikl profili va DNK belgichalari: zanjir ajraladi, praymer birikadi, yangi zanjir quriladi, soni har siklda ikki barobar (16 tagacha ko‘rsatiladi) | L2, C3 |
| 47,5–59,5 | 5 Signal | Optik modul: har sikl oxirida nur manbai chaqnaydi, filtr g‘ildiragi keyingi rang kanaliga buriladi, detektor yonadi; pastda kuchayish egri chiziqlari sikl sayin o‘sadi | L4, C6, C4, C5 |
| 59,5–73,5 | 6 Natija | Monitor; egri chiziqlar plato; chegara chizig‘i va Cq nuqtalari o‘qqa tushiriladi (raqamsiz) | L5, C7 |
| 73,5–77 | — | Yakun kartochkasi | — |

Ataylab ko‘rsatilmaydi: sikl harorati va vaqti, sikllar soni, Cq qiymatlari, bo‘yoq/zond nomlari. Sxemadagi optik
yo‘l soddalashtirilgan va animatsiya uni “to‘g‘irlamaydi” (nur probirkaga chizilmaydi) — [README → Topilmalar](README.md#topilmalar).

## Fayllar (ffprobe va sha256 bilan o‘lchangan)

<!-- samples:begin -->
| Fayl | Davomiylik | O‘lcham, fps | Kodek | Audio | Hajm | sha256 |
|---|---|---|---|---|---|---|
| `gc_ms_en.mp4` | 96.00 s | 720×1280, 24 | h264 | 0 | 1.87 MB | `7bea57f2cd232d4bb202db54c56ab29325b2c470cba9b3ce8b32c57fc9ab84c7` |
| `gc_ms_en.srt` | — | — | srt | — | 1830 B | `04a1ff57e9d2325dad5737dcf4b7c8ea83e433ccd33b89d03bccd9cd9496475a` |
| `gc_ms_en.vtt` | — | — | vtt | — | 1838 B | `9f3b588e519e26d2d9860296cfefdf08dd725dac776060f09eeb0403f5d01e84` |
| `gc_ms_ru.mp4` | 96.00 s | 720×1280, 24 | h264 | 0 | 1.92 MB | `639d6e9c0879db2b8f8ff7a2429bc4dd71b74779a1274f4d12836d2930c289d6` |
| `gc_ms_ru.srt` | — | — | srt | — | 2847 B | `be2a34cb69afe3b3f04cf559811ddcd33f77f070b6b2e99504973c479d703aea` |
| `gc_ms_ru.vtt` | — | — | vtt | — | 2855 B | `5cc157a6714fa49890e3e3a0eab7824641d77c155cb1a604e1da67b4dcfb700d` |
| `gc_ms_uz.mp4` | 96.00 s | 720×1280, 24 | h264 | 0 | 1.90 MB | `17fd1262b8a9a5a8cd383c805666c033811d68408f46dfeb589d2d8ee07e9433` |
| `gc_ms_uz.srt` | — | — | srt | — | 1832 B | `59add21a5c4fa19450bdbd1ead4cfbaa2359670e14ff02f27be69333a9ae40a3` |
| `gc_ms_uz.vtt` | — | — | vtt | — | 1840 B | `5b593be74b42de5f0f19a7fc9d4ad6e723ee95d3d3519e6ece1b7c52797b5a20` |
| `real_time_pcr_en.mp4` | 77.00 s | 720×1280, 24 | h264 | 0 | 1.37 MB | `f38a67d1bc8391e56e87d7d9343a16be70f9713d43046bcc56e1f29fd91f522d` |
| `real_time_pcr_en.srt` | — | — | srt | — | 1609 B | `b44709ba5131250f668755536c0f35bb30ebe9356106c91e6a34618d6972e75f` |
| `real_time_pcr_en.vtt` | — | — | vtt | — | 1617 B | `d30a62b687a8907bfc975e6d87acf013a4464168cbd336606512df8f5c841bfd` |
| `real_time_pcr_ru.mp4` | 77.00 s | 720×1280, 24 | h264 | 0 | 1.40 MB | `161cf1dcc589eaadf5ecd63e2ec5ba66eddc487ca154ffa0ec843a54db3b88b7` |
| `real_time_pcr_ru.srt` | — | — | srt | — | 2531 B | `1b667d8fad1a29691d484caa2a64eca603cc6cb51244e2ebff4001668620c415` |
| `real_time_pcr_ru.vtt` | — | — | vtt | — | 2539 B | `bbdd09a9ffd2608baef6e1d858ca8fb4ea902a6bb98311ef2b0459b5e0f2dde4` |
| `real_time_pcr_uz.mp4` | 77.00 s | 720×1280, 24 | h264 | 0 | 1.38 MB | `0136f9054e4c2c910d958fe8b3e422ae58edc6c4a81681e81eec6a2266a281be` |
| `real_time_pcr_uz.srt` | — | — | srt | — | 1640 B | `ec7fab60fdb4045f42c0419a0943063af14d040ac47a5fc84e53e0bc248a35e0` |
| `real_time_pcr_uz.vtt` | — | — | vtt | — | 1648 B | `060788bc0c5501d7cd556f6b590462c0e391191b0307613610f6965567e2e358` |
<!-- samples:end -->

Barcha MP4 larda audio oqimlari soni 0 (ovozsiz). ru va en subtitrlar — tarjima, `docs/L10N_REVIEW_QUEUE.md`
tartibida ko‘rib chiqilmagan.

## Ko‘zdan kechirish (kadrlar ko‘rildi)

- GC-MS uz: 1, 6, 15, 25, 36, 37, 44, 46, 49, 55, 56, 58, 64, 66, 76, 90, 91 s (pleyer kadri) va tayyor MP4 dan 57,
  68, 87 s; ru/en: 6, 36, 57, 66, 88 s.
- PCR uz: 7, 18, 27, 30, 33,2, 34,4, 35, 38,5, 44, 52, 57, 63, 71 s; tayyor en MP4 dan 28, 44, 56, 70 s.
- Ko‘rib tuzatilgan kamchiliklar: uzun subtitr 4 qatorga sig‘madi → kartochka 176 px, 3–4 qator, shrift 34→25 px;
  jarayon sahnalarida fokus halqasi animatsiyani yopardi → u sahnalarda o‘chirildi va kamera yaqinlashuvi
  kamaytirildi; natija panelida sarlavhalar ustma-ust tushardi → qisqa sarlavha; PCR sikl profilida yorliq
  sarlavhaga tegardi → pastga surildi; ru “Результат” bosqich nomi sig‘ishi tekshirildi.

## Qayta yig‘ish

```sh
export NODE_PATH=$(npm root -g)
node tool/video/lessons/render_sample.cjs gc_ms --lang uz --preview 6,36,57   # PNG: build/lesson_samples/preview/
node tool/video/lessons/render_sample.cjs gc_ms            # uz/ru/en MP4 + SRT/VTT (~3,5 daqiqa / til)
node tool/video/lessons/render_sample.cjs real_time_pcr    # (~2,8 daqiqa / til)
python3 tool/video/lessons/report_samples.py               # shu jadval (ffprobe, sha256)
```

Natija deterministik emas bayt darajasida (ffmpeg/Chromium versiyasiga bog‘liq) — sha256 shu ishga tushirishniki.

## Yo‘q narsalar (halollik)

- Diktor ovozi yo‘q. Repoda o‘zbekcha TTS uchun yordamchi skript bor (`tool/video/uz_tts_chatterbox.py`), lekin u
  tashqi ochiq model repozitoriyasi va og‘irliklarini talab qiladi — ular bu muhitda yo‘q, skript ishlatilmadi;
  ovoz aktyori ham yo‘q. To‘liq darslar uchun ovoz rejasi — `README.md`.
- Qolgan 27 dars uchun animatsiya yo‘q — faqat storyboard.
- Mutaxassis ko‘rigi o‘tkazilmagan.
