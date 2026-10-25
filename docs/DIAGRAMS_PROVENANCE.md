# Sxemalar (diagrammalar) — kelib chiqishi va huquq holati

Yangilangan: 2026-10-25. Fayllar: `assets/diagrams/<mavzu>.<til>.png` (18 ta: 6 mavzu × uz/ru/en),
1920×1280 PNG (ilovada 960×640 nisbat, 2× aniqlik), har biri ≤ 150 KB. Ilovada ko‘rsatish:
`lib/app/widgets/diagram_figure.dart` (`DiagramFigure`, bosilsa kattalashtirib ko‘rish), alt-matn va izoh —
ARB kalitlari `imgDiagram*` (uz/ru/en).

## Joriy holat: ORIGINAL_CREATED_IN_REPO

- **Nima:** 18 ta yangi sxema — shu repozitoriyda **2026-10-25** da noldan yaratilgan original ish.
- **Vosita:** `tool/diagrams/gen_diagrams.py` (sof Python → SVG, matn Inter shrifti metrikalari bilan
  o‘lchanadi) va `tool/diagrams/render.cjs` (Playwright Chromium, 2× → PNG, pngquant). SVG manbalar
  repoda: `tool/diagrams/svg/<mavzu>.<til>.svg`. Qayta yaratish:
  `python3 tool/diagrams/gen_diagrams.py && NODE_PATH=$(npm root -g) node tool/diagrams/render.cjs --quant`.
- **Tarkibi:** faqat to‘rtburchak/romb bloklar, o‘qlar, oddiy chiziqli belgilar (lampa, filtr, kyuveta,
  detektor) va matn. **Uchinchi tomon materiali yo‘q:** fotosurat yo‘q, logotip yo‘q, ishlab chiqaruvchi
  (OEM) dizayni yo‘q, boshqa ilova/sayt rasmi yo‘q, chizmadan nusxa ko‘chirilmagan. Ranglar — ilovaning
  o‘z palitrasi (`lib/design/tokens.dart`). Matn shrifti — Inter (SIL Open Font License,
  `assets/fonts/Inter-OFL.txt`; OFL shriftni rasmga chiqarishga ruxsat beradi).
- **Eski rasmlardan foydalanilmagan:** eski 18 ta rasmning maketi, grafikasi va matni ko‘chirilmagan;
  eskilaridan faqat qaysi ekranda va qaysi mavzuda ko‘rsatilishi olindi (fayl nomlari ilova kodi ishlashi
  uchun saqlandi). Yangi kompozitsiya: raqamli qadamlar, qaror rombi (Ha/Yo‘q tarmoqlari), natija bloklari;
  fotometriyada optik yo‘l chizmasi.
- **Mazmun manbalari:** `docs/DIAGRAMS_CONTENT_SOURCES.md` — har bir gap → ilovadagi manba
  (Westgard 1981, WHO LQMS 2011, WHO phlebotomy 2010, WHO/DIL/LAB/99.1, WHO basic laboratory manual 2003,
  ilovadagi fotometriya ma’ruzasi — Aripov 2006) yoki `STANDARD_TEXTBOOK` / `NEEDS_EXPERT`.
  Yangi raqam, chegara yoki qoida qo‘shilmagan.
- **Egasi qabuli:** egasi tomonidan alohida qayd etiladi — bu hujjatda egasi nomidan tasdiq **yozilmaydi**.
  Qolgan ish: `docs/DIAGRAMS_OWNER_DECLARATION_DRAFT.md`.
- **Tekshiruv (2026-10-25):** 18 PNG to‘liq o‘lchamda va telefon kengligida (~390 px) ko‘zdan kechirildi
  (ustma-ust tushish, kesilish, imlo); eng kichik matn — 28 birlik (960 kenglikdagi kanvasda), ya’ni 390 px
  kenglikda ≈ 11,4 px (formulalardagi pastki indekslar 22–24 birlik). Har bir matn qatori sig‘ishi generator
  tomonidan tekshiriladi.

## Fayllar (yangi, joriy)

| Fayl | Mavzu | Til | Ko‘rsatiladi | PNG sha256 | SVG manba sha256 | Uchinchi tomon kontenti | Holat |
|---|---|---|---|---|---|---|---|
| `calibration_overview.uz.png` | Kalibrlash tartibi / Calibration workflow | uz | `lib/features/instruments/calibration_screens.dart` (CalibrationScreen, tepada) | `8d2d098c9475394482cb7f6c1b15e9ef6239f018dd7b2653efba87d45e7be198` | `ea5aac842d42e60de9d3a1a4d4d9a9c132e444f1ecc59c21a43807ca816faf64` | yo‘q | ORIGINAL_CREATED_IN_REPO |
| `calibration_overview.ru.png` | Kalibrlash tartibi / Calibration workflow | ru | `lib/features/instruments/calibration_screens.dart` (CalibrationScreen, tepada) | `81379dc1fdc2402f04477f8189255de464bd64e80f462f0c31240ace4d2d9937` | `325962c07006014ca80b92ca9b19704f2b5d2cddbccd80d58ccb137043ecc94e` | yo‘q | ORIGINAL_CREATED_IN_REPO |
| `calibration_overview.en.png` | Kalibrlash tartibi / Calibration workflow | en | `lib/features/instruments/calibration_screens.dart` (CalibrationScreen, tepada) | `6dbd777558244cc59d2713e71812a92644d2a1b5c61329c6e8aefe6a6ecc6b0d` | `867c27991619c98b3b910d7c60602539f1d5ae4fe4686cca775ec6991d5275f6` | yo‘q | ORIGINAL_CREATED_IN_REPO |
| `differential_count.uz.png` | Leykoformula / Manual differential | uz | `lib/features/differential/differential_screens.dart` (DifferentialScreen, hero ostida) | `19e6707fa04a3f3a9929ac8e898c0268deca4b6fc7ee2bef7572feb21596a2b0` | `936492f2dc7aaeb64c04c8c8c7a85491bab6c944e34f7f12e890b08e8d98118c` | yo‘q | ORIGINAL_CREATED_IN_REPO |
| `differential_count.ru.png` | Leykoformula / Manual differential | ru | `lib/features/differential/differential_screens.dart` (DifferentialScreen, hero ostida) | `87626f2a49101ed17db1df58d012f969723ac8f19618865fc99fe47e6aeedf25` | `0a291f01b102880e94572a80429010c94a7d128781bd4cfe9458948b8e8bba32` | yo‘q | ORIGINAL_CREATED_IN_REPO |
| `differential_count.en.png` | Leykoformula / Manual differential | en | `lib/features/differential/differential_screens.dart` (DifferentialScreen, hero ostida) | `bf5d565df5eb8452577515a4faeda0585e824f070cb1ee82b0473edbc0c29c8f` | `116b5493fa6ec3384a6e918bacc20a665d476982dc39a098f9ac504c81dc5efb` | yo‘q | ORIGINAL_CREATED_IN_REPO |
| `educational_feedback.uz.png` | Test natijasidan o‘rganish / Learning from a quiz | uz | `lib/features/learn/learn_screens.dart` (_QuizResult, xatolar tahlili ostida) | `12bcc3935bd1f2757e32e8d7278c255b26fb6bd16437d9fee63dea098da18841` | `133ca8cc959c988e812f49c9b7ac3b79c7503a00b6e93f5f872e4b51d818eaba` | yo‘q | ORIGINAL_CREATED_IN_REPO |
| `educational_feedback.ru.png` | Test natijasidan o‘rganish / Learning from a quiz | ru | `lib/features/learn/learn_screens.dart` (_QuizResult, xatolar tahlili ostida) | `c08ed782c65818e6bd1ea41e291bb129e44a655809c1e0fef9fc68485345306f` | `dfe6526e832687898dacc01fe33e6d3a936393f2eaca6a87051426979b9247cd` | yo‘q | ORIGINAL_CREATED_IN_REPO |
| `educational_feedback.en.png` | Test natijasidan o‘rganish / Learning from a quiz | en | `lib/features/learn/learn_screens.dart` (_QuizResult, xatolar tahlili ostida) | `b9cf3fb2dd0a49aa002c46bbfc8765a2e3d0bf9bae540d73f1aafb3e58b2965f` | `626d40c8930a9d4889bd4b21985990eae5f338dc35f7cbd1d16aea8008946aa2` | yo‘q | ORIGINAL_CREATED_IN_REPO |
| `photometry.uz.png` | Absorbsion fotometriya / Photometry | uz | `lib/features/instruments/instrument_screens.dart` (fotometrik/biokimyo apparat kartasi) | `03b2320195baf3e4e1d083f1c1f1fbc110d00371ce8c8e198d54ef801209f93a` | `b2d12e474b9195e8ddc31d6f487779f23e244315292dfaa2e1e56df1fa2460f6` | yo‘q | ORIGINAL_CREATED_IN_REPO |
| `photometry.ru.png` | Absorbsion fotometriya / Photometry | ru | `lib/features/instruments/instrument_screens.dart` (fotometrik/biokimyo apparat kartasi) | `94ede7db0b1d884a8bc4dc8c18d806c3cdcca3ca2b938808d0f2637b814f9ebf` | `1352456fdc875fd1eb3c023536089cd9ed2e6722ed5ac103f37447f0b5e6e224` | yo‘q | ORIGINAL_CREATED_IN_REPO |
| `photometry.en.png` | Absorbsion fotometriya / Photometry | en | `lib/features/instruments/instrument_screens.dart` (fotometrik/biokimyo apparat kartasi) | `a2671c193f1098b8750465d12ba9d99718d8f0f22935e3726289d37a82ae8496` | `8343d7f9d2e8e2316d79ae44646c4260655cab727ccd8ac138acb2b93ed06f66` | yo‘q | ORIGINAL_CREATED_IN_REPO |
| `preanalytics.uz.png` | Preanalitik bosqich / Preanalytics | uz | `lib/features/lab/lab_screens.dart` (PreanalyticsScreen, bosqichlar ostida) | `e50bd8b19d0a6a41484e0540b630a9b52e262e7594059b2e56ddc4a910b90a38` | `33d518f1517f56367ea9d0121e2f7e5b8c04e3e9ea3eb5e740191a42ab0b4513` | yo‘q | ORIGINAL_CREATED_IN_REPO |
| `preanalytics.ru.png` | Preanalitik bosqich / Preanalytics | ru | `lib/features/lab/lab_screens.dart` (PreanalyticsScreen, bosqichlar ostida) | `bdfa71a192a159a1ee1c7d47c02e0445e454729aa1ad416039cffa70fda3a45b` | `1c9aeb0ce0f2f84396ef5cb475533b7a0cfdcd0e226bc34b11a437ec12dfedf1` | yo‘q | ORIGINAL_CREATED_IN_REPO |
| `preanalytics.en.png` | Preanalitik bosqich / Preanalytics | en | `lib/features/lab/lab_screens.dart` (PreanalyticsScreen, bosqichlar ostida) | `f7de1daa98d7c24e50bc052a6d5d1f39cc0baa446d00dc9c776d34b73c933b8b` | `3a8d8ab373674b1c571494235f4e16aa3eecadd24f31189a3d59994d43d5eb7b` | yo‘q | ORIGINAL_CREATED_IN_REPO |
| `qc_decision.uz.png` | QC seriyasi: qabul yoki rad / QC run decision | uz | `lib/features/qc/qc_screens.dart` (QcScreen, kirish ostida) | `dc8334b06a56eefab1aac1b54c68487a6d8d2e93f62ce933294083f1ce2e0a95` | `cf6d59b615bf6814543f8813fa811540d511e92bba6e7b534ea465208a3b694c` | yo‘q | ORIGINAL_CREATED_IN_REPO |
| `qc_decision.ru.png` | QC seriyasi: qabul yoki rad / QC run decision | ru | `lib/features/qc/qc_screens.dart` (QcScreen, kirish ostida) | `8e88aab2785c3a18d002ee96a9933a9d2d244d747ebc4f943063135e10564b0c` | `8336bdd7e3a308d0e77844f0565b6c1867f6cc005164078f3c08294a4cc1bb93` | yo‘q | ORIGINAL_CREATED_IN_REPO |
| `qc_decision.en.png` | QC seriyasi: qabul yoki rad / QC run decision | en | `lib/features/qc/qc_screens.dart` (QcScreen, kirish ostida) | `7310121e663df14d51669eb0137aac158b8d2aadf62bc8aa28e8173c6e8b75bb` | `dcdc5a3981b6b2aebae95ef4eac3fbcb5b17d846b37dc91e7f6cc81257b857bb` | yo‘q | ORIGINAL_CREATED_IN_REPO |

## Eski 18 ta rasm — iste’moldan chiqarildi (RETIRED)

2026-10-24 da egasi yuklagan `LabGuide_GLOBAL_MASTER_2026-10-24` paketidan
(`03_TAYYOR_DIAGRAMMALAR`) kelgan 18 ta rasmning **muallifi noma’lum** edi (paketda muallif, litsenziya,
metama’lumot yo‘q; egasining faqat og‘zaki bayoni bor edi; holat `OWNER_CONFIRMATION_PENDING` edi).
Shuning uchun ular shu commitda `assets/` dan **olib tashlandi** (xuddi shu fayl nomlari yangi original
rasmlar bilan almashtirildi). Eski fayllar **git tarixida qoladi** (masalan, commit `35091cf` va undan oldingi);
ularni ilovadan tashqarida (sayt, do‘kon materiallari) ishlatmang. Qayd uchun eski sha256:

| Fayl (eski) | eski sha256 | Holat |
|---|---|---|
| `calibration_overview.uz.png` | `c99b6471e25191c0432609bb02f1858cb57e24ce8e2cdffd6f3f2465df122054` | RETIRED_UNKNOWN_AUTHORSHIP |
| `calibration_overview.ru.png` | `d18a55fcbd66fbb6e1dce193e31da88f32722f76f0ce776ee7d7a3c1ae0a9974` | RETIRED_UNKNOWN_AUTHORSHIP |
| `calibration_overview.en.png` | `65ebf953a8d7ac4a0e605a779dfa4f05eb834c23e97c58927bea0b4d8fabafbd` | RETIRED_UNKNOWN_AUTHORSHIP |
| `differential_count.uz.png` | `0a3d92daa679fd4b14087d745b9e7ac7c115cbf808cb7eb47903f6cc06d2f595` | RETIRED_UNKNOWN_AUTHORSHIP |
| `differential_count.ru.png` | `e7b45f88ee87882badb8ada9e66fc9f4322703e2be728b018601bf85eca39d0d` | RETIRED_UNKNOWN_AUTHORSHIP |
| `differential_count.en.png` | `737341ae9ccb6897eb184b6251825a7308e44c71dc062bcd71954bb63a530e7e` | RETIRED_UNKNOWN_AUTHORSHIP |
| `educational_feedback.uz.png` | `81673cf2dddae5fa7b8c5967b56c51b576b6fea339b229cfd7c591f3f3ae129d` | RETIRED_UNKNOWN_AUTHORSHIP |
| `educational_feedback.ru.png` | `3043b84375dd34ba417f7149fd3fe99da19afbd484c5b491880dd54956cecc3a` | RETIRED_UNKNOWN_AUTHORSHIP |
| `educational_feedback.en.png` | `447817f63c794d64a3d609cf14a7e3c7eebd71c6c350bd8c12d15c35e547dd6e` | RETIRED_UNKNOWN_AUTHORSHIP |
| `photometry.uz.png` | `17e7f19fefe7bdff5cee6c245720e8d057c58fc9ecacdc4a52c5a0d03eafb062` | RETIRED_UNKNOWN_AUTHORSHIP |
| `photometry.ru.png` | `f2dc1edc870435fff67e48b7b4479cd88a937f5073bbc0fd982e4501880bfd0b` | RETIRED_UNKNOWN_AUTHORSHIP |
| `photometry.en.png` | `50c1ca01aef0897232299192ee9b62b9dc22dae4e037599ffc1193e506eae118` | RETIRED_UNKNOWN_AUTHORSHIP |
| `preanalytics.uz.png` | `f94c5fbe3b31c9e86ba17d7fe85236e58757016dd311a363638c641529c47dce` | RETIRED_UNKNOWN_AUTHORSHIP |
| `preanalytics.ru.png` | `643c3fb8432ac420673e16d7fd28c852b2cac4ee1c3c97629f4d0becd9263c9b` | RETIRED_UNKNOWN_AUTHORSHIP |
| `preanalytics.en.png` | `c50788f4b95c2df6537eed50f934b468bcccee3015ca72663be9fb740c769afc` | RETIRED_UNKNOWN_AUTHORSHIP |
| `qc_decision.uz.png` | `021090e740e0681c5c93d2657933b129b85378b53af3e01f06c7cb60cf349e07` | RETIRED_UNKNOWN_AUTHORSHIP |
| `qc_decision.ru.png` | `217afce71b593ce4728cb80d4095c64aa9a9c194dfde2c17b8229ae89e8c490e` | RETIRED_UNKNOWN_AUTHORSHIP |
| `qc_decision.en.png` | `5491cab79b29facbd0aa3846bf2b75598669983bcac87f84518a1d567f4c14ab` | RETIRED_UNKNOWN_AUTHORSHIP |

## NEEDS_EXPERT (qisqacha; to‘liq ro‘yxat — `docs/DIAGRAMS_CONTENT_SOURCES.md`)

1. `qc_decision`: 1-2s ni har seriyada ogohlantirish deb ko‘rsatish (ilova qarori D-20) — klinik-kimyo mutaxassisi.
2. `calibration_overview`: “qabul” sharti (vakolatli shaxs + kalibrlashdan keyingi QC) — ilova qoidasi,
   registry `CALIB-ACCEPTANCE-RULES` (AWAITING_EXPERT).
3. `differential_count`: “yomon surtma — yangisini tayyorlang” (WHO 2003 dan xulosa); blast/aniqlanmagan
   hujayrada yo‘llash matni (registry `DIFF-REFER-BODY-WORDING`).
4. `photometry`: A = log₁₀(I₀/I) va A = ε·ℓ·c — `STANDARD_TEXTBOOK`; uz/ru atamalari; filtr o‘rniga
   monoxromator bo‘lishi mumkin.
5. `preanalytics`: “Namuna yaroqlimi?” qarori — yaroqlilik mezonlari laboratoriya SOP’iga topshirilgan.
6. Til: ru/uz qisqa sxema iboralari — tibbiy tilshunos ko‘rigi.
