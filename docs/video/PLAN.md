# Video qo‘llanmalar rejasi (2026-10-25)

Egasi topshirig‘i (25-okt): har asosiy bo‘lim uchun video qo‘llanma — **halol**. Bu yerda faqat
haqiqatan ishlaydigan, serversiz ekranlar ko‘rsatiladi (`docs/VIDEO_FEATURE_INVENTORY.md`).

## Provenance (kelib chiqishi)

| | |
|---|---|
| Yaratilgan | 2026-10-25 |
| Kadrlar | `tool/video/howto_walk_test.dart` (+ `tool/video/video_walk.dart`) — ilovaning haqiqiy ekranlari, Flutter widget-test render; haqiqiy kontent paketi, serversiz, mehmon (hisobsiz), rol — laborant, Klassik mavzu, yorug‘, telefon 390×844 @2x; tillar uz/ru/en |
| Subtitrlar | `tool/video/storyboards.json` (yagona manba: kadr tartibi, soniya, uz/ru/en matn); atamalar ilova ARB’idan |
| Yig‘ish | `tool/video/compose.py` (PIL + ffmpeg): 720×1280, H.264, 24 fps, subtitrlar kadrga yozilgan, alohida SRT/VTT; bosish joyi — to‘q sariq doira (faqat kadrda haqiqatan bosilgan joy) |
| Hujjat/hisobot | `tool/video/report.py`: storyboard jadvallari va `docs/video/OUTPUTS.md` (ffprobe, sha256) |
| Ovoz | **Yo‘q.** Diktor yoki TTS vositasi yo‘q — har video «ovozsiz, subtitrli ekran yozuvi — diktorsiz» (kartochkada ham yozilgan). Hech bir fayl «tayyor ovozli video» deb atalmaydi |
| Oldingi pipeline | `docs/TUTORIAL_VIDEOS.md` (`tool/screenshots/tutorial_*`) — shu usul asosida |

Kadrlar ichidagi namuna qiymatlar (Glucose 5,0 ± 0,2; REF 10121; kreatinin 88 µmol/L va h.k.) — faqat
ko‘rsatish uchun, haqiqiy bemor yoki laboratoriya ma’lumoti emas.

## Mavzular

| # | Mavzu | Hujjat (storyboard) | How-to bo‘limi | Video |
|---|---|---|---|---|
| 1 | Kalibrlash (+ jurnal) | `01_kalibrlash.md` | `calibration` | uz/ru/en MP4 + SRT/VTT |
| 2 | Sifat nazorati (Levey–Jennings, Westgard, EQA) | `02_sifat_nazorati.md` | `qc` | uz/ru/en |
| 3 | Preanalitika | `03_preanalitika.md` | `preanalytics` | uz/ru/en |
| 4 | Kalkulyatorlar | `04_kalkulyatorlar.md` | `calculators` | uz/ru/en |
| 5 | Apparatlar va metodikalar | `05_apparatlar.md` | `instruments` | uz/ru/en |
| 6 | Mikroskopiya atlasi (+ mashq) | `06_mikroskopiya.md` | `microscopy` | uz/ru/en |
| 7 | Najas tahlili va parazitologiya | `07_najas_parazitologiya.md` | `coprology` | uz/ru/en |
| 8 | Bilim va malakani baholash | `08_bilim_baholash.md` | `assessment` | uz/ru/en (ru/en — Profil sozlamasi kadri bilan) |
| 9 | Testlar, og‘zaki savollar va natijalar | `09_testlar_natijalar.md` | — | uz/ru/en (og‘zaki savollar — 8-videoda) |
| 10 | Boshqa asosiy funksiyalar (leykoformula, sitologiya, spermogramma, qon guruhi, gistologiya, siydik, qon morfologiyasi, koagulogramma) | `10_boshqa_funksiyalar.md` | `differential` … `coagulogram` | uz/ru/en |

Har hujjatda: nega kerak, qanday ishlaydi, qanday foydalaniladi, natija, qisqa kirish matni, STORYBOARD
(kadr, haqiqiy marshrut, amal, uz/ru/en subtitr, soniya), maqsadli davomiylik, kerakli ekran yozuvlari,
ma’lum cheklovlar va alohida (uzunroq) ilmiy dars rejasi — **NEEDS_EXPERT** belgisi bilan, faqat ilova va
repoda allaqachon keltirilgan manbalar.

## Qilinmaydigan videolar (halollik)

| Funksiya | Sabab |
|---|---|
| Guruhlar / ustoz / topshiriqlar | Server va hisob kerak (`ClassesGate`); serversiz ekran «mavjud emas» deydi. 2026-10-18 dagi tutoriallar soxta server bilan yozilgan — bu turkumga kirmaydi |
| Hamjamiyat | Server kerak; serversiz karta umuman ko‘rinmaydi |
| Oflayn paketlar | Yuklab olish uchun tarmoq kerak; storyboard ham yozilmadi |
| Pro / to‘lov, hamkor reklama | Ilovada yo‘q / build bayrog‘i bilan o‘chirilgan |

## Qayta yig‘ish

```sh
export PATH=/root/sdk/flutter/bin:$PATH
flock /tmp/flutter_test.lock flutter test tool/video/howto_walk_test.dart --update-goldens   # ~1,5 daqiqa
python3 tool/video/compose.py                 # 30 ta MP4 + SRT/VTT → build/video_out/ (~4 daqiqa)
python3 tool/video/compose.py --subs-only     # faqat SRT/VTT
python3 tool/video/compose.py --lang uz --topic 02_sifat_nazorati --preview   # PNG ko‘rib chiqish
python3 tool/video/report.py                  # storyboard jadvallari + OUTPUTS.md
```

Bitta til: `--name ' uz$'` (walk test) va `--lang uz` (compose). Kadr id lari storyboarddagi id lar bilan
bir xil bo‘lishi shart — `compose.py` farqni xato bilan to‘xtatadi. UI matni o‘zgarsa: walk testni qayta
yurgizing, kadrlarni ko‘zdan kechiring, subtitrni `storyboards.json` da yangilang.

## “Qanday foydalaniladi?” bilan bog‘liqlik

Har bo‘limning ilova ichidagi qadamlari (`lib/features/howto/howto_registry.dart`, ARB `howTo…`) shu
storyboardlardan olingan. Video hozircha ilovaga qo‘shilmagan: `HowToContent.videoUrl` bo‘sh, oynada video
haqida hech narsa ko‘rsatilmaydi. Video joylashtirilsa — faqat havola (https) ro‘yxatga yoziladi; video
pleyer bog‘liqligi qo‘shilmaydi.
