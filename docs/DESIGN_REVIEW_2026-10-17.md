# Dizayn sharhi, 17-oktabr 2026

Maqsad (egasi): "Odamlarni jalb qiladigan, sayqallangan premium ilova.
Ko'rinish mayin, yumshoq (mayin, yumshoq) bo'lsin." Ushbu hujjat — ekran
rasmlari asosidagi ko'rik, nima o'zgartirildi, nima faqat taklif (sababi
bilan) va yangi dizayn tokenlari.

Qanday ko'rildi: `tool/screenshots/*_test.dart --update-goldens` bilan
rasmlar olindi va har biri ko'zdan kechirildi — onboarding (til → welcome →
kirish → rol), har to'rt rol bosh sahifasi va 5 tab, profil, kutubxona,
tor ekran (320 px), katta shrift (1,3x / 1,6x), tungi rejim.

Rasmlar git'ga kirmaydi (`tool/screenshots/out/` — mahalliy). Qayta olish:

```
flutter test tool/screenshots/walk_ux_onboarding_test.dart --update-goldens
flutter test tool/screenshots/walk_roles_test.dart --update-goldens
flutter test tool/screenshots/walk_ux_stress_test.dart --update-goldens
```

"Oldin" rasmlari `tool/screenshots/out/before/<ssenariy>/` ga ko'chirib
qo'yilgan; "keyin" — o'sha nomli `tool/screenshots/out/walk/<ssenariy>/`.

> Eslatma: test golden'larida `BoxShadow` xiralashtirilmaydi — soya ostida
> "qattiq kulrang plastinka" bo'lib chiqadi (avvalgi rasmlarda ham tugmalar
> ostida shunday edi). Qurilmada soya yumshoq; rasmlarni shu bilan o'qing.

## Topilmalar — birinchi taassurot va qaytib kelishga ta'siri bo'yicha

| # | Ta'sir | Nima topildi | Oldin (rasm) | Holat |
|---|---|---|---|---|
| 1 | Juda yuqori | **Welcome qiymatni aytmaydi.** Yagona panelda "UZ · RU · EN · Telefon va planshet" va rollar ro'yxati — "bu ilova menga nima beradi?" savoliga javob yo'q. | `before/ux_onb_uz/02_welcome.png` | **O'zgartirildi** — har rol uchun bittadan 3 afzallik (ikonka badge + kimga + nima), brend belgisi orqasida yumshoq nur, mayin kirish animatsiyasi; asosiy tugma birinchi ekranda (`walk/ux_onb_ru/02_welcome.png`) |
| 2 | Juda yuqori | **Bosh sahifa kartalarining hammasida "Ochish".** Ierarxiya yo'q, karta ichida nima borligi aytilmaydi. | `before/roles_lab_uz/01_bosh.png`, `before/roles_teacher_uz/01_bosh.png` | **O'zgartirildi** — har kartada bir qatorli ma'noli izoh ("eGFR, ACR, suyultirish va boshqalar", "Hisoblagich va hujayralar atlasi", "Talabalar va topshiriqlar"…), ikonka yumshoq badge ichida, kartalar ketma-ket mayin paydo bo'ladi |
| 3 | Yuqori | **Tor ekranda (320 px) "Kalkulyatorla / r"** — sarlavha harfma-harf bo'linadi. | `before/ux_w320_uz/01_home.png` | **Tuzatildi** — to'r katak kengligini beradi, uzun so'z bir qatorga sig'guncha sarlavha biroz kichrayadi (kamida 13 px); test bilan |
| 4 | Yuqori | **Suzuvchi pastki panel kontentni yopadi.** Ro'yxat oxiri panel ustida atigi 16 px qolardi; Lab tugmasi ko'tarilib turgani uchun "Guruhlarni ochish" kabi tugma panelga yopishib ko'rinardi. | `before/roles_teacher_uz/01_bosh.png` | **Tuzatildi** — shell ichida ro'yxat oxirida panel (Lab tugmasi bilan) ustida 24 px; har tab uchun regressiya testi (oxirgi element panel tepasidan ≥ 16 px yuqorida) |
| 5 | Yuqori | **Umumiy "qattiqlik"**: sarlavhalar juda siqiq (harf oralig'i −1,7), kartalar orasidagi ajralish faqat rang bilan, ba'zi kartalarda qattiq chegara (Kunlik savol, qidiruv maydoni), sparkle bosish effekti "shovqinli". | `before/roles_lab_uz/02_bosh_past.png` | **O'zgartirildi (tokenlar orqali, butun ilovada)** — pastdagi "Yangi tokenlar" bo'limi |
| 6 | O'rta | **Onboarding rasmlarida logotip o'rnida kulrang kvadrat.** Bu ilova xatosi emas — skript rasmni oldindan yuklamagan. | `before/ux_onb_uz/01_til.png`, `02_welcome.png` | **Tuzatildi (skript)** — `walk_ux_onboarding_test.dart` logotipni oldindan yuklaydi |
| 7 | O'rta | **Bo'sh/xato holatlari quruq**: bitta ikonka kvadratda. | (kod: `LgStateView`) | **O'zgartirildi** — yumshoq kompozitsiya (`LgStateArt`): xira doiralar, "molekula" nuqtalari, soyali karta ichida ikonka; butun ilovadagi barcha bo'sh/xato holatlarga birdaniga |
| 8 | O'rta | **Yuklanishda spinner** (sarlavhasiz `LgStateView(loading)` — hamjamiyat, admin, mikroskopiya, apparatlar, takrorlash…). | — | **O'zgartirildi** — spinner o'rniga kontur (`LgSkeleton`): ro'yxat qatorlariga o'xshash xira shakllar, screen reader "Yuklanmoqda…" eshitadi. Sarlavhali yuklanish ("Kontent yuklanmoqda…") avvalgidek |
| 9 | O'rta | **Til tanlash ekrani**: logotip "yalang'och". | `before/ux_onb_uz/01_til.png` | **O'zgartirildi** — welcome bilan bir xil yumshoq nur (halo) |
| 10 | O'rta | O'rganish tabida hero karta birinchi ekranning ~70 % ini egallaydi; ish tugmalari (mavzular, test) pastda. | `before/roles_lab_uz/09_learn.png` | **Taklif** — pastda |
| 11 | Past | Tungi rejim: lime aksent biroz "kislotali", yumshoq fon (`soft`) to'q-yashil to'yingan. | `before/roles_doctor_ru_katta/01_bosh.png`, `before/ux_dark_uz/05_lab.png` | **O'zgartirildi** — aksent va `soft` to'yinganligi pasaytirildi (kontrast testlari o'tadi) |
| 12 | Past | Shifokor qo'llanmasi kartasida "11 систем" tegi (neutral) panel ustida fondan to'qroq "teshik" bo'lib ko'rinadi. | `before/roles_doctor_ru_katta/02_bosh_past.png` | **Taklif** — pastda |

## Har bir ekran — tekshiruv ro'yxati

Skript: `tool/screenshots/walk_all_screens_test.dart` — 62 marshrut, har
biri tepasi va bir surilgandan keyin, ikki ko'rinishda:
`walk/all_uz_light_390/` (uz · kunduzgi · 390 px) va
`walk/all_ru_dark_320/` (ru · tungi · 320 px) — jami 248 rasm, hammasi
ko'zdan kechirildi. Belgilar: **T** — tuzatildi, **Tk** — taklif,
**—** — muammo topilmadi. "(test)" — faqat golden muhitidagi holat
(rasm oldindan yuklanmagan), qurilmada yo'q.

| Ekran (marshrut) | Topilgan | Holat |
|---|---|---|
| Til tanlash | logotip "yalang'och" | T — halo |
| Welcome | qiymat aytilmaydi, CTA pastda | T — 3 afzallik, CTA birinchi ekranda |
| Kirish / OTP / Rol | — (rol kartalari toza, tanlangan holat aniq) | — |
| Bosh (`/home`), 4 rol | hamma kartada "Ochish"; 320 px da "Kalkulyatorla/r"; qattiq chegarali qidiruv | T |
| Bosh — Kunlik savol kartasi | ingichka brend chegara "arzon" ko'rinadi | T — soya |
| Bosh — Toifa kartasi (laborant) | chegarali, Kunlik kartadan farqli uslub | Tk (toifa — tegilmaydi) |
| Qidiruv (`/home/search`) | bo'sh holat — ma'lumot bloki, yaxshi; fokus chegarasi tungi rejimda yorqin lime | — |
| Tahlillar (`/tests`) | ru 320: filtr chiplari gorizontal suriladi (kesilgan chip — ataylab "yana bor" ishorasi) | — |
| Tahlil kartasi (glyukoza) | manba havolalari qalin, tagi chizilgan | T — iqtibos uslubi |
| Kasallik bo'yicha tahlillar / holat | — (bo'limlar raqamli belgisi va rangli ikonkalari izchil) | — |
| Lab (`/lab`) | Sitologiya/Spermogramma/Qon guruhi/Gistologiya kartalarida rasm o'rni bo'sh oq kvadrat | (test) |
| QC, QC yangi, EQA | bo'sh holat — yangi illyustratsiya; maydonlar va chiplar izchil | T (bo'sh holat) |
| Kalibrlash, jurnal | jurnal bo'sh holati — yangi illyustratsiya | T |
| Kalkulyatorlar ro'yxati, eGFR, suyultirish, kamera | manbalar qalin/tagi chizilgan | T |
| Preanalitika | ingliz tilidagi manba lokatorlari ("Other steps to prepare") uz/ru matn ichida | Tk — kontent (tibbiy matn, tegilmadi) |
| Apparatlar, gematologiya, BS-240 | model rasmida bo'sh maydon | (test) |
| Mikroskopiya atlasi, bo'lim, rasm | "Bu nima?" kartasida doira o'rinlari bo'sh | (test) |
| Leykoformula, hujayralar, hujayra | ru 320: "Гиперсегментированн/ый" so'z bo'linadi | T — FitLongWordText |
| Leykoformula — hisoblagich, tarix, talqin | tarix bo'sh holati — yangi illyustratsiya; manbalar | T |
| Sitologiya, hujayralar, Bethesda | ro'yxatda ba'zi rasm o'rinlari bo'sh | (test) |
| Spermogramma, chegaralar, hisoblagich | manbalar qalin | T |
| Qon guruhi, moslik | manbalar qalin | T |
| Gistologiya, to'qimalar | manbalar qalin | T |
| Qon morfologiyasi, eritrotsitlar | hero rasm o'rni bo'sh | (test) |
| Siydik tahlili, test-chiziq, cho'kma | — | — |
| Kutubxona, saqlanganlar, paketlar | saqlanganlar bo'sh holati — yangi illyustratsiya | T |
| Kitob va qo'llanmalar | ba'zi kitob nomlari KATTA HARFDA (manba nomi) | Tk — kontent |
| Manbalar va litsenziyalar | 289 ta qalin tagi chizilgan havola — sahifa "ko'k" | T |
| Ilmiy ish maydoni | — | — |
| O'rganish (`/learn`) | hero rasm o'rni bo'sh (test); hero birinchi ekranning katta qismi | Tk (yuqoridagi 1-taklif) |
| Izohli test, jadvallar, kunlik, imtihon | — (chiplar, raqamli qadamlar izchil) | — |
| Profil, rol, maxfiylik, aloqa | — | — |
| Taklif va yordam (server yo'q) | holat — yangi illyustratsiya | T |
| Foydalanish shartlari | — | — |
| Barcha ichki sahifalar — yig'ilgan sarlavha | uzun sarlavha til tugmasiga yopishadi ("…(EQA)UZ") | T — 8 px oraliq |
| Barcha tab sahifalari — ro'yxat oxiri | panel ostida qolardi | T — 24 px |
| Dialog / bottom sheet / snackbar | snackbar radiusi tokenlardan; dialog — `LgRadius.card` (26) | T |
| Admin konsoli | sarlavhasiz yuklanish — spinner o'rniga skeleton | T |
| Classroom (guruhlar, ma'ruza) | tegilmadi (parallel ish) — yangi tokenlar avtomatik qo'llanadi (LgPanel, LgTile, LgStateView); `classroom_screens.dart` va `topic_test_screens.dart` dagi `LgStateView(loading, title: l.classesLoading)` — sarlavhali, shuning uchun spinner qoladi | Tk — egasiga: sarlavhasiz qilsa skeleton bo'ladi |
| Toifa | tegilmadi; `ToifaEntryCard` chegarali — Kunlik kartasi uslubiga keltirish | Tk — egasiga |

Admin, hamjamiyat, guruh ichki sahifalari server talab qiladi (bu buildda
"Server hali ulanmagan" holati) — ular `test/widget/*` dagi soxta server
bilan tekshiriladi va ko'rinishi umumiy vidjetlardan (LgPanel, LgRow,
LgStateView) keladi.

## Oldin / keyin (rasm yo'llari)

Hammasi `tool/screenshots/out/` ichida.

| Ekran | Oldin | Keyin |
|---|---|---|
| Til tanlash | `before/ux_onb_uz/01_til.png` | `walk/ux_onb_uz/01_til.png` |
| Welcome (uz / ru / en) | `before/ux_onb_{uz,ru,en}/02_welcome.png` | `walk/ux_onb_{uz,ru,en}/02_welcome.png` |
| Kirish | `before/ux_onb_uz/03_auth.png` | `walk/ux_onb_uz/03_auth.png` |
| Rol | `before/ux_onb_uz/06_role.png` | `walk/ux_onb_uz/06_role.png` |
| Bosh — laborant | `before/roles_lab_uz/01_bosh.png`, `02_bosh_past.png` | `walk/roles_lab_uz/01_bosh.png`, `02_bosh_past.png` |
| Bosh — ustoz | `before/roles_teacher_uz/01_bosh.png` | `walk/roles_teacher_uz/01_bosh.png` |
| Bosh — talaba / shifokor | `before/roles_student_uz/01_bosh.png`, `before/roles_doctor_uz/01_bosh.png` | `walk/roles_student_uz/…`, `walk/roles_doctor_uz/…` |
| Lab, Kutubxona, O'rganish, Profil | `before/roles_lab_uz/05_lab.png`, `07_library.png`, `09_learn.png`, `11_profil.png` | `walk/roles_lab_uz/` (o'sha nomlar) |
| Tungi + katta shrift (ru) | `before/roles_doctor_ru_katta/01_bosh.png` | `walk/roles_doctor_ru_katta/01_bosh.png` |
| 320 px | `before/ux_w320_uz/01_home.png` | `walk/ux_w320_uz/01_home.png` |
| Katta shrift 1,6x | `before/ux_big_uz/01_home.png` | `walk/ux_big_uz/01_home.png` |
| Tungi Lab | `before/ux_dark_uz/05_lab.png` | `walk/ux_dark_uz/05_lab.png` |

## Yangi dizayn tokenlari ("mayin" yangilanish)

Hammasi `lib/design/tokens.dart` va `lib/design/theme.dart` da — ekranlar
alohida tuzatilmagan, butun ilova birdaniga o'zgaradi.

**Ranglar** (`LgPalette`; WCAG AA testlari — `app_flow_test.dart` — o'tadi):

| Token | Kunduzgi: oldin → keyin | Tungi: oldin → keyin | Nega |
|---|---|---|---|
| `soft` | `#E8EEDB` → `#E9EFE1` | `#253F31` → `#223A31` | sariq-yashil to'yinganlik kamaydi, osoyishtaroq |
| `line` | `#DCE4D9` → `#E1E7DE` | `#304641` → `#2C413D` | ajratuvchi chiziqlar yumshoqroq |
| `brand` | `#194C40` (o'zgarmadi) | `#C5E8A1` → `#BFE0A8` | tungi lime "kislotali" emas, mayinroq |

Qolgan ranglar (fon, matn, `outline` — boshqaruv chegaralari 3:1) o'zgarmadi.

**Radiuslar** (`LgRadius`): hero 27 → **30**, karta 23 → **26**, tugma
18 → **20**, chip 14 → **16**, maydon 14 → **16**, yangi `notice` = **18**
(ogohlantirish bloklari, snackbar, kichik rasmlar).

**Soyalar** (`LgShadow`, yangi): qattiq chegara o'rniga ikki qatlamli yumshoq
soya — keng "ambient" (alfa 0,045, blur 28, y 10) + yaqin "key" (alfa 0,03,
blur 6, y 2). `LgShadow.raised` — asosiy tugma va holat ikonkasi uchun
kuchliroq (0,10/22/8 + 0,05/4/1). Tungi rejimda soya ko'rinmaydi — bo'sh
ro'yxat qaytadi, sirt rangi ajratadi. Qo'llanildi: `LgPanel` (paper),
`LgTile`, `LgHeroCard`, `LgButton` (primary), bosh sahifa qidiruv maydoni,
Kunlik savol kartasi (chegarasi olib tashlandi; tunda — juda xira chet).

**Tipografika** (`theme.dart`): o'lchamlar o'zgarmadi; sarlavhalarning harf
oralig'i yumshatildi — display −1,7 → **−1,1**, headlineMedium −1,2 →
**−0,8**, headlineSmall −0,9 → **−0,6**, titleLarge −0,3 → **−0,2**; qator
balandligi biroz oshdi (1,08 → 1,10; 1,15 → 1,18; 1,2 → 1,22). Natija:
"Bilim. Aniqlik. Amaliyot." siqilgan emas, osoyishta o'qiladi.

**Harakat** (`LgMotion`): sahifa o'tishi 200 → **260 ms**, bosish 160 →
**180 ms**, bosishda masshtab 0,975 → **0,97** (`pressScale`), yagona egri
chiziq `curve = easeOutCubic`, yangi `enter = 320 ms` — kirish animatsiyasi.
Yangi `LgFadeIn` vidjeti: xiradan paydo bo'lish + 12 px ko'tarilish,
`delay` bilan ketma-ket (stagger). Reduced motion yoqilgan bo'lsa — hammasi
darhol, animatsiyasiz.

**Bosish effekti**: `InkSparkle` → `InkRipple`, splash alfa 0,08, highlight
0,04 (brend rangida) — "uchqun" o'rniga mayin to'lqin.

## O'zgartirilgan fayllar

- `lib/design/tokens.dart` — ranglar, radiuslar, `LgShadow`, `LgMotion`.
- `lib/design/theme.dart` — tipografika, ripple, snackbar radiusi.
- `lib/design/widgets/lg_widgets.dart` — `LgPressable` (yangi masshtab/egri
  chiziq), `LgButton`/`LgPanel`/`LgHeroCard`/`LgNotice` (soya, radius),
  `LgTile` (badge + ma'noli izoh + tor katakda sarlavhani sig'dirish),
  `LgTwoColumnGrid` (katak kengligini beradi), `LgStateView` + yangi
  `LgStateArt`, `LgSkeleton`, `LgFadeIn`.
- `lib/features/auth/ui/welcome_screen.dart` — 3 afzallik, halo, kirish
  animatsiyasi; `language_picker_screen.dart` — halo.
- `lib/features/home/home_screen.dart` — har amalga izoh (`HomeAction.caption`),
  kartalar ketma-ket paydo bo'ladi.
- `lib/features/home/global_search.dart` — qidiruv: chegara o'rniga soya,
  ikonka brend rangida.
- `lib/features/daily/daily_screens.dart` — Kunlik savol kartasi: chegara
  o'rniga soya.
- `lib/app/widgets/lg_page.dart` — shell ichida ro'yxat oxiri 16 → 24 px.
- `lib/app/widgets/lg_page.dart` — yig'ilgan sarlavha va til tugmasi orasida 8 px.
- `lib/features/tools/clinical_calc_screens.dart` (`CalcSourceTile`) va
  `lib/features/content/ui/analyte_screen.dart` (`SourceTile`) — iqtiboslar
  14 px oddiy matn rangida, tagi chizilmagan; havola ekanini ikonka aytadi
  (butun ilovadagi manbalar ro'yxatlari shu ikki vidjetdan).
- `lib/features/differential/differential_screens.dart` — hujayra nomi tor
  ekranda harfma-harf bo'linmaydi.
- `tool/screenshots/walk_all_screens_test.dart` — barcha ekranlar ko'rigi.
- ARB (faqat yangi kalitlar, uch tilda): `welcomeBenefit*`, `homeTile*`,
  `stateLoading`. Mavjud izohlar qayta ishlatildi: `labQcSub`,
  `labMicroscopySub`, `analytePracticeSub`, `libSourcesSub`, `libResearchSub`.
- Testlar: yangi `test/widget/design_polish_test.dart`; `admin_console_test`
  — sarlavhasiz yuklanishda endi `LgSkeleton` kutiladi.

Tibbiy mazmun va raqamlar o'zgartirilmadi. `classroom`, `toifa`,
`tool/slides`, `assets/lectures` ga tegilmadi.

## Faqat taklif (amalga oshirilmadi) — sababi bilan

1. **O'rganish tabidagi hero kartani ixchamlashtirish** (bosh sahifadagi
   kabi `compact: true`). Sabab: `learn_screens.dart` va
   `learn_title_fit_test` sarlavha sig'ishini aniq tekshiradi; ekran
   tarkibini o'zgartirish — mahsulot qarori (hero bu tabning "yuzi").
   Tavsiya: rasm balandligi 150 → 110, yoki compact hero + mavzular ro'yxati
   birinchi ekranda.
2. **Rolga mos welcome** (rol tanlashdan oldin). Hozir 3 afzallik uch rol
   guruhiga mos. Rolni welcome'dan oldin so'rash oqim tartibini va
   `walk_smoke`/onboarding testlarini o'zgartiradi — alohida qaror.
3. **Neutral teg tungi rejimda** (`LgTone.neutral` foni `bg` — panel ustida
   "teshik"). `paper`/`soft` ga o'tkazish kerak, lekin teg toifa va
   classroom ekranlarida ham ishlatiladi — ular parallel tahrirlanmoqda;
   birlashtirgandan keyin.
4. **Skeleton "shimmer" animatsiyasi.** Hozir statik: cheksiz animatsiya
   testlardagi `pumpAndSettle` ni to'xtatib qo'yadi va reduced motion bilan
   murakkablashadi. Kerak bo'lsa — `TickerMode`/test bayrog'i bilan.
5. **Hero (umumiy element) animatsiyalari** — masalan, Lab kartasidagi
   rasm → bo'lim sarlavhasi. go_router + `StatefulShellRoute` da Hero
   tablar orasida ziddiyat beradi; foyda kichik, xavf o'rtacha.
6. **Toifa kartasi** (bosh sahifa, laborant) hali chegarali — `lib/features/toifa`
   ga tegilmadi; Kunlik savol kartasi bilan bir xil uslubga keltirish kerak.
   **Bajarildi (2026-10-18):** `ToifaEntryCard` va `ToifaTodayCard` — chegara o'rniga
   `LgShadow.card`, tunda xira chet (Kunlik karta bilan bir xil); test `design_polish_test`.
   Shu bilan birga sarlavhali yuklanish holatlari (sinflar, mavzu testi) —
   `LgSkeleton(caption: …)` (spinner o'rniga kontur, sarlavha izoh va ovozli yorliq).
7. **Store skrinshotlari** (`store_screenshots_test.dart`) yangi dizayn bilan
   qayta olinishi kerak — do'kon sahifasi birinchi taassurotning bir qismi.

## Avvaldan bor muammolar (bu ishga aloqasiz)

- `walk_smoke_test.dart` — eGFR qadamida `TextField` topilmaydi (65-qator):
  kalkulyator ekrani o'zgargan, skript eskirgan.
- `walk_library_test.dart` — en va ru-tungi ssenariylari bu o'zgarishlardan
  oldin ham yiqilardi (ko'rib chiqilmadi).
Ikkalasi ham `tool/` skriptlari, `flutter test` to'plamiga kirmaydi.
