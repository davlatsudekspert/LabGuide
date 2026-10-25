# Video qo‘llanmalarni ilovaga ulash — yetkazish rejasi (2026-10-25)

**Holat: TAKLIF — egasi qarorini kutadi.** Kod tayyor, lekin ilova bilan keladigan ro‘yxat
(`assets/howto/videos.json`) bo‘sh: do‘kondagi ilovada video tugmasi **ko‘rinmaydi**, hech qayerga hech narsa
yuklanmagan, haqiqiy manzil yozilmagan. Egasi hostingni tanlab, fayllarni o‘zi joylagach, bitta JSON fayl
to‘ldiriladi (6-bo‘lim).

## 1. Nima bor

- 30 ta MP4: 10 mavzu × uz/ru/en, 720×1280, H.264, **ovozsiz, subtitrlar kadrga yozilgan**, har biri
  0,9–1,9 MB, jami ≈ 40,6 MB (`docs/video/OUTPUTS.md`, `docs/video/PLAN.md`). Yonida SRT/VTT subtitrlar.
  Fayllar gitda yo‘q (`build/video_out/`).
- 16 ta “Qanday foydalaniladi?” bo‘limi. Moslik `docs/video/PLAN.md` bo‘yicha: 8 bo‘lim — o‘z videosi
  (1–8-mavzu); 8 bo‘lim (leykoformula … koagulogramma) — bitta umumiy 10-video, har biri o‘z joyidan
  (7-bo‘limdagi jadval); 9-mavzu (testlar va natijalar) — how-to bo‘limi yo‘q, ro‘yxatga kirmaydi.
- Matnli qo‘llanma (qadamlar + natija, uz/ru/en) ilova ichida, **internetsiz** ishlaydi — o‘zgarmaydi.

## 2. Repoda tekshirib bo‘ladigan infratuzilma

| Narsa | Repodagi dalil | Video uchun |
|---|---|---|
| Cloudflare Worker `labguide-api` + D1 (`workers.dev`) | `cloudflare/wrangler.toml` (izohda “bepul tarif”) | API uchun; R2/statik fayl bog‘lamasi **yo‘q**. Video berish uchun Worker kodi kerak bo‘lardi — tavsiya etilmaydi |
| Statik sayt `labguide.nfcstore.uz` (Cloudflare Pages — taklif) | `site/README.md` (“1-variant: Cloudflare Pages”), ilovadagi havolalar shu domenga | Haqiqatan joylanganmi — **NEEDS_OWNER_CHECK** |
| Oflayn paketlar — `raw.githubusercontent.com/davlatsudekspert/LabGuide/main/packs/` | `lib/app/app_scope.dart`, `docs/store/PRIVACY_POLICY.md` 2-bo‘lim (GitHub IP manzilni ko‘radi — allaqachon yozilgan) | MP4 ni gitga qo‘shish repo tarixini har qayta yig‘ishda +40 MB o‘stiradi — **yo‘q** |
| GitHub Releases | Repoda ishlatilmaydi | Mumkin (fayl git tarixiga kirmaydi); cheklovlar — **NEEDS_OWNER_CHECK** |
| Cloudflare R2 / Stream | Repoda yo‘q | Narx, bepul limit, karta talabi — **NEEDS_OWNER_CHECK** |

Narxlar va limitlar bu hujjatda **taxmin qilinmaydi**: har biri hosting sahifasida egasi tomonidan tekshiriladi.

## 3. Variantlar

| | (a) Ilova ichida | (b) Statik https hosting, tashqi ochish | (c) Ilovada ixtiyoriy yuklab olish | (d) YouTube (unlisted) |
|---|---|---|---|---|
| Ilova hajmi | **+≈ 40 MB** hammaga (MP4 qayta siqilmaydi; foydalanuvchi o‘qimaydigan 2 til ham) | +0 (faqat ≈ 5 KB JSON) | +0, lekin pleyer/fayl ochish plagini kerak | +0 |
| Internetsiz | Ha | Yo‘q (matnli qo‘llanma — ha) | Yuklangandan keyin — ha | Yo‘q |
| Til | Uchala til hammaga | Faqat o‘z tili ochiladi | Faqat o‘z tili yuklanadi | O‘z tili (alohida havola) |
| Yangi bog‘liqlik | Pleyer yoki faylni tashqi ilovaga berish (iOS’da asset’ni tashqi ilovada ochish qiyin) | Yo‘q (`url_launcher`, `http` bor) | Pleyer yoki `open_file`-turidagi plagin, saqlash joyi, o‘chirish UI | Yo‘q |
| Maxfiylik | Tarmoq yo‘q | Host IP, vaqt, qaysi fayl (bo‘lim+til) ko‘radi; cookie/identifikator yo‘q | (b) bilan bir xil + qurilmada fayl | Google kuzatuvi, reklama, tavsiyalar; siyosatga Google/YouTube qo‘shiladi |
| Do‘kon | Muammo yo‘q, faqat hajm | Tashqi havola — odatiy; to‘lov yo‘q | Muammo yo‘q | Muammo yo‘q, lekin maxfiylik yorlig‘i murakkablashadi |
| Yangilash | Faqat ilova relizi | Yangi fayl nomi + ro‘yxat (reliz) | (b) kabi + qurilmadagi keshni yangilash | YouTube’da almashtirish, havola o‘zgaradi |
| Boshqaruv | — | To‘liq egasida | To‘liq egasida | YouTube qoidalari, “unlisted” = havolasi bor har kim ko‘radi |

**Tavsiya: (b)** — har bo‘lim × til uchun alohida https manzil, video tizim brauzeri/pleyerida ochiladi
(ilovada pleyer yo‘q). Keyinroq kerak bo‘lsa (c) ustiga qo‘shiladi (xuddi shu ro‘yxat, sha256 bilan).
Hosting tanlovi (egasi): **Cloudflare** (sayt bilan bir domen — `labguide.nfcstore.uz/howto/v1/`, Cloudflare
siyosatda allaqachon tarmoq xizmati sifatida bor) yoki **GitHub Releases** (GitHub siyosatda allaqachon bor).
Ikkalasida ham narx/limit — **NEEDS_OWNER_CHECK**; bizning eng katta fayl 1,9 MB, jami ≈ 41 MB.

## 4. Ilovada qanday ishlaydi (kod tayyor)

- **Ma’lumot:** `assets/howto/videos.json` (`schema_version: 1`, `owner_approval`, `videos[]`); har yozuv —
  `section`, `lang`, `url`, `bytes`, `seconds`, `sha256`, ixtiyoriy `start_seconds`. Tekshiruvchi
  (`lib/features/howto/howto_videos.dart`) rad etadi: noma’lum bo‘lim, noma’lum til, https emas (login/
  `#fragment` bilan ham), joy egallovchi domen (`.invalid`, `example.com`, `localhost` …), hajm/soniya/sha256
  yo‘q yoki noto‘g‘ri, takror bo‘lim+til, bitta fayl turli hajm/hash bilan, noma’lum maydon, `owner_approval`siz
  yozuv. Buzuq fayl — ro‘yxat bo‘sh (matnli qo‘llanma ishlayveradi), xato faqat debug konsolda.
- **Til:** faqat ilova tilidagi video. Ilova tilida yo‘q bo‘lsa — tugma **yo‘q**, boshqa tildagisi jim
  ko‘rsatilmaydi (subtitrlar kadrga yozilgan: begona tildagi video o‘qib bo‘lmaydi). `make_manifest.py` har
  mavzu uchun uchala til bo‘lishini talab qiladi, shuning uchun amalda bu holat chiqmaydi.
- **UI:** qadamlar va natija ostida ikkinchi darajali tugma **“Videoni ko‘rish (1,3 MB)” / “Смотреть видео
  (1,3 МБ)” / “Watch the video (1.3 MB)”** — hajm ochishdan oldin ko‘rinadi (mobil internet). Ostida: “Ovozsiz,
  subtitrli ekran yozuvi · 0:46 · brauzer yoki video pleyerda ochiladi”; umumiy videoda yana “Videoda bu bo‘lim
  0:18 dan boshlanadi” (pastga yaxlitlanadi). “Tez orada” kabi joy egallovchi yo‘q.
- **Tarmoq:** oyna ochilganda so‘rov **yo‘q**. Bosilganda bitta `HEAD` so‘rovi (8 s): internet yo‘q →
  “Video uchun internet kerak. Matnli qo‘llanma shu yerda — u internetsiz ishlaydi.”; fayl yo‘q (404) yoki hajmi
  ro‘yxatdagidan boshqa → “Video hozir ochilmadi. Keyinroq urinib ko‘ring — matnli qo‘llanma shu yerda.”;
  aks holda mavjud `openExternalLink` (ochilmasa — havola nusxalanadi va aytiladi).
- **Yaxlitlik:** ilova faylni o‘zi yuklamaydi, shuning uchun sha256 ni qurilmada tekshirmaydi; `HEAD`
  dagi `Content-Length` ro‘yxatdagi bayt bilan solishtiriladi. sha256 — joylashdan oldin va keyin egasi
  tomonida (`SHA256SUMS`, 6-bo‘lim) va kelajakdagi (c) uchun.

## 5. Siyosat, do‘kon, qulaylik

- **Maxfiylik:** ilovada kuzatuv, analitika, cookie yo‘q; `HEAD` va video so‘rovida identifikator yo‘q. Host
  (Cloudflare yoki GitHub) har veb-sayt kabi IP manzil, vaqt, brauzer/`User-Agent` va qaysi fayl so‘ralganini
  (ya’ni bo‘lim va ilova tili) ko‘radi va o‘z siyosatiga ko‘ra log qilishi mumkin. Video ochilgach — tizim
  brauzeri/pleyerining o‘z siyosati. **E’lon qilishdan oldin** `docs/store/PRIVACY_POLICY.md` 2-bo‘limiga
  (uz/ru/en) “Video qo‘llanmalar” bandi qo‘shiladi (host nomi bilan) va sayt qayta yasaladi
  (`tool/site/build_site.py`). Qorovul buni talab qiladi (host nomi siyosatda bo‘lmasa test yiqiladi).
- **Do‘kon:** tashqi havolada ochiladigan o‘quv videosi — to‘lov, obuna, kirish yo‘q. App Store “App
  Privacy” va Play “Data safety” javoblari: ishlab chiquvchi ma’lumot yig‘maydi; uchinchi tomon hostingi
  IP ko‘rishi oflayn paketlar (GitHub) bilan bir xil — aniq so‘zlash **NEEDS_OWNER_CHECK**. Do‘kon izohida
  video ilova ichida deb yozilmasin.
- **Qulaylik:** subtitrlar kadrga yozilgan (doim ko‘rinadi, ovoz yo‘q — eshitmaydiganlar uchun to‘liq).
  SRT/VTT ham joylanadi (kelajakdagi veb/ilova pleyeri uchun). Ko‘rmaydiganlar uchun video foydasiz —
  ularga **matnli qo‘llanma** (ekran o‘quvchi o‘qiydi) asosiy; subtitr matni so‘zma-so‘z storyboard
  jadvallarida (`docs/video/NN_*.md`). Tugma va xabar ekran o‘quvchiga o‘qiladi (xabar — live region).

## 6. Egasi nima qiladi (ketma-ketlik)

1. Hostingni tanlaydi (3-bo‘lim) va narx/limitni tekshiradi. `docs/DECISIONS.md` ga sarlavhasida “video”
   so‘zi bor qaror yozadi (masalan, `## D-71. How-to videolari: … hosting (sana)`).
2. Fayllarni oxirgi marta yig‘adi (`docs/video/PLAN.md`) va ro‘yxatni yasaydi:
   ```sh
   python3 tool/video/make_manifest.py build/video_out \
     --base-url https://<tanlangan-host>/labguide/howto/v1 \
     --approval D-71 --out assets/howto/videos.json \
     --sha256sums build/howto_upload/SHA256SUMS --stage build/howto_upload
   ```
   Fayl nomi: `<mavzu>_<til>.<sha256 dan 8 belgi>.mp4` (va `.vtt`/`.srt`) — fayl o‘zgarsa nom ham
   o‘zgaradi: kesh muammosi yo‘q, eski ilova versiyalari eski faylni ochaveradi.
3. **Egasi** `build/howto_upload/` ichidagini hostingga yuklaydi (agent yuklamaydi). Tavsiya: `Content-Type:
   video/mp4`, uzoq kesh (`Cache-Control: public, max-age=31536000, immutable`) — host sozlamasi
   **NEEDS_OWNER_CHECK**.
4. Tekshiradi: `cd build/howto_upload && sha256sum -c SHA256SUMS`; har manzil uchun
   `curl -sI <url>` → `200` va `Content-Length` ro‘yxatdagidek.
5. Maxfiylik siyosatiga band qo‘shadi, saytni qayta yasaydi (5-bo‘lim).
6. Testlar (`flutter test`, `tool/run_guards.sh`) — keyin odatiy reliz. Telefonda: uz/ru/en, Wi-Fi va
   uchish rejimi.

**Rollback.** Darhol: hostingdan faylni o‘chirish/nomini o‘zgartirish — ilova “Video hozir ochilmadi”
deydi (halol, buzilmaydi). Keyingi relizda: `videos` ni `[]` ga qaytarish — tugma yo‘qoladi. Eski
fayllar eski ilova versiyalari ishlatilayotgan muddatda saqlanadi (jami ≈ 41 MB).

**Keyingi bosqich (ixtiyoriy):** ro‘yxatni `packs/index.json` kabi masofadan o‘qish (relizsiz yangilash;
lekin har oyna ochilishida tarmoq so‘rovi bo‘ladi) va (c) — ilovada keshlab qo‘yish. Hozir kerak emas.

## 7. Bo‘lim → video → til (namuna, 2026-10-25 09:46 UTC holati)

Namuna `docs/video/videos.sample.json` (`tool/video/make_manifest.py build/video_out` chiqishi,
manzillar ataylab `https://NEEDS-OWNER-HOST.invalid/…` — ilova rad etadi) va `docs/video/SHA256SUMS.sample`
(30 MP4 + 60 SRT/VTT, yuklanadigan nomlar bilan). Videolar shu kuni qayta yig‘ilgan — hajm/sha256
`OUTPUTS.md` dagidan farq qilishi mumkin; **joylashdan oldin ro‘yxat qayta yasaladi** (6-bo‘lim, 2-qadam).

| # | Bo‘lim (`id`) | Video (mavzu) | uz | ru | en | Bo‘lim boshlanishi |
|---|---|---|---|---|---|---|
| 1 | Kalibrlash (`calibration`) | `01_kalibrlash_<til>` | 0:46 · 1.30 MB | 0:46 · 1.34 MB | 0:46 · 1.23 MB | — |
| 2 | Sifat nazorati (`qc`) | `02_sifat_nazorati_<til>` | 0:46 · 1.28 MB | 0:46 · 1.32 MB | 0:46 · 1.21 MB | — |
| 3 | Preanalitika (`preanalytics`) | `03_preanalitika_<til>` | 0:31 · 0.97 MB | 0:31 · 1.04 MB | 0:31 · 0.95 MB | — |
| 4 | Kalkulyatorlar (`calculators`) | `04_kalkulyatorlar_<til>` | 0:33 · 0.98 MB | 0:33 · 1.01 MB | 0:33 · 0.94 MB | — |
| 5 | Apparatlar (`instruments`) | `05_apparatlar_<til>` | 0:47 · 1.49 MB | 0:47 · 1.53 MB | 0:47 · 1.42 MB | — |
| 6 | Mikroskopiya (`microscopy`) | `06_mikroskopiya_<til>` | 0:43 · 1.22 MB | 0:43 · 1.28 MB | 0:43 · 1.22 MB | — |
| 7 | Najas tahlili (`coprology`) | `07_najas_parazitologiya_<til>` | 0:41 · 1.39 MB | 0:41 · 1.43 MB | 0:41 · 1.42 MB | — |
| 8 | Bilim va malakani baholash (`assessment`) | `08_bilim_baholash_<til>` | 0:59 · 1.54 MB | 1:04 · 1.86 MB | 1:04 · 1.80 MB | — |
| 9 | Leykoformula (`differential`) | `10_boshqa_funksiyalar_<til>` | 0:56 · 1.82 MB | 0:56 · 1.80 MB | 0:56 · 1.78 MB | 0:06 |
| 10 | Sitologiya (`cytology`) | `10_boshqa_funksiyalar_<til>` | 0:56 · 1.82 MB | 0:56 · 1.80 MB | 0:56 · 1.78 MB | 0:18 |
| 11 | Spermogramma (`spermogram`) | `10_boshqa_funksiyalar_<til>` | 0:56 · 1.82 MB | 0:56 · 1.80 MB | 0:56 · 1.78 MB | 0:25 |
| 12 | Qon guruhi (`bloodGroup`) | `10_boshqa_funksiyalar_<til>` | 0:56 · 1.82 MB | 0:56 · 1.80 MB | 0:56 · 1.78 MB | 0:28 |
| 13 | Gistologiya (`histology`) | `10_boshqa_funksiyalar_<til>` | 0:56 · 1.82 MB | 0:56 · 1.80 MB | 0:56 · 1.78 MB | 0:32 |
| 14 | Siydik tahlili (`urinalysis`) | `10_boshqa_funksiyalar_<til>` | 0:56 · 1.82 MB | 0:56 · 1.80 MB | 0:56 · 1.78 MB | 0:38 |
| 15 | Qon morfologiyasi (`bloodMorph`) | `10_boshqa_funksiyalar_<til>` | 0:56 · 1.82 MB | 0:56 · 1.80 MB | 0:56 · 1.78 MB | 0:42 |
| 16 | Koagulogramma (`coagulogram`) | `10_boshqa_funksiyalar_<til>` | 0:56 · 1.82 MB | 0:56 · 1.80 MB | 0:56 · 1.78 MB | 0:45 |

`09_testlar_natijalar_<til>` (0:46, ≈ 1,3 MB) — how-to bo‘limi yo‘q; xohlansa, keyinroq alohida joyga
(masalan, “O‘rganish” sahifasi) ulanadi — alohida qaror.

## 8. Fayllar

| Fayl | Nima |
|---|---|
| `assets/howto/videos.json` | Ilova o‘qiydigan ro‘yxat (hozir bo‘sh) |
| `lib/features/howto/howto_videos.dart` | Tekshiruvchi, yuklovchi, `HEAD` tekshiruvi |
| `lib/features/howto/howto_registry.dart` | `HowToVideo`, `HowToContent.videos` / `videoFor(til)` |
| `lib/features/howto/howto_widgets.dart` | Tugma, izoh, internet yo‘q xabari |
| `tool/video/make_manifest.py` (+ `test_make_manifest.py`) | O‘lchash (bayt, soniya, sha256), ro‘yxat, `SHA256SUMS`, lokal `--stage` |
| `test/unit/howto_videos_test.dart`, `test/widget/howto_video_test.dart`, `test/guards/howto_videos_guard_test.dart` | Testlar va qorovul (`docs/GUARDS.md`) |
| `tool/screenshots/walk_howto_video_test.dart` | Soxta ro‘yxat bilan ekran rasmlari (uz 390, ru tungi 320, en 820) |
