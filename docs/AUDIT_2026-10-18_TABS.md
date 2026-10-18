# Tablar auditi — Lab tabidan tashqari (2026-10-18)

Doira: onboarding (til, xush kelibsiz, mehmon, email OTP, Google/Apple tugmalari, rol),
Bosh sahifa (4 rol), Tahlillar (qidiruv, 119 analit kartasi), Kutubxona, O‘rganish
(guruh va sinf, ma’ruza/taqdimot, izohli test, imtihon, kunlik savollar), Profil (mavzu,
til, yordam, murojaatlar, hisobni o‘chirish, maxfiylik), admin ekranlari.
**Lab tabi** — boshqa agent. **Toifa** (50 savollik test, bilet, og‘zaki savollar, kunlik
toifa progressi), **barcha mavzu testlari** va sinf test oqimi — koordinator qarori bilan
audit o‘rtasida boshqa agentga o‘tkazildi: `lib/features/toifa/`,
`lib/features/classroom/topic_test*.dart`, `topic_questions.dart` ga tegilmadi (Toifa
mashqiga qilingan avtomatik surish tuzatishi qaytarib olindi — pastda 6-band).

## Usul

* **iPhone o‘lchami:** 390×844, DPR 3, notch (47/34), `TargetPlatform.iOS`
  (BouncingScrollPhysics). Qo‘shimcha: 360×640 va 320×568, shrift ×1.3; uz/ru/en;
  kunduzgi/tungi; Klassik va Ivory.
* **Avtomatik zond** (vaqtincha testlar, commitga kirmagan): har bir doiradagi yo‘l
  (≈60 ta) ochildi va oxirigacha surildi; har kadrdagi barcha `RenderParagraph` tekshirildi:
  istisno (overflow), `didExceedMaxLines` (qirqilgan matn), ARB kalitiga o‘xshash matn
  (tarjima qilinmagan), «Draft/Qoralama/Черновик», «Pro/Premium/obuna/reklama» so‘zlari,
  boshqa til harflari (ru da o‘zbekcha, en da kirill).
* **Server holatlari:** soxta server bilan kirgan ustoz; `myGroups`, `myThreads`,
  `assignments`, `groupMembers`, `groupTopics`, `myAccess` — `network` va `unknown`
  xatolari bilan 16 ta ekran × 3 til (cheksiz spinner, «Qayta urinish» tugmasi bormi).
* **Tab almashish:** izohli test o‘rtasida boshqa tabga o‘tib qaytish (sessiya saqlanadi),
  Ilmiy ish maydonidagi matn saqlanadi, tabni qayta bosish ildizga qaytaradi — hammasi to‘g‘ri.
* **Admin:** egasi hisobi (2FA) bilan 11 ta admin ekrani × 3 til, 360×640 ×1.3 —
  istisno va qirqilgan matn yo‘q.
* **Ekran rasmlari:** `tool/screenshots/walk_audit_tabs_test.dart`
  (`flutter test tool/screenshots/walk_audit_tabs_test.dart --update-goldens`;
  rasmlar `tool/screenshots/out/walk/audit_*`, repoga kirmaydi) — ko‘zdan kechirildi.
* **Tibbiy mazmun:** `assets/content/core/pack.json` — 119 analit, 1182 da’vo, 41 qaror
  chegarasi skript bilan tekshirildi: **har bir da’vo va har bir chegarada manba bor**, osilib
  qolgan manba ID yo‘q. Ilovada umumiy referens oraliq berilmaydi (`reference_intervals`
  bo‘sh — oraliq laboratoriya IFU siga bog‘lanadi), faqat manbali qaror chegaralari.

## Natijalar jadvali

| # | Ekran | Muammo | Daraja | Tuzatish / test | Holat |
|---|---|---|---|---|---|
| 1 | Onboarding → til tanlash | 360×640 ×1.3 va 320×568 (iPhone SE 1) da **«O‘zbekcha» kartasi ekrandan pastda** — surmaguncha ko‘rinmaydi; asosiy auditoriya tili yashirin. | Yuqori | `language_picker_screen.dart`: joy yetmasa logo va globus belgisi yashiriladi (logo keyingi ekranda bor). Test: `language_picker_test.dart :: audit: all three languages visible…` (3 o‘lcham), `…keeps the logo` | Tuzatildi |
| 2 | O‘rganish → Izohli test; Kunlik savollar (Bosh sahifa/O‘rganish) | Kichik telefonda javob bosilgach **to‘g‘ri/xato izohi va «Keyingi» ekrandan pastda** — natija ko‘rinmaydi, har savolda qo‘lda surish kerak. | O‘rta | Yangi `lib/design/widgets/reveal_on_mount.dart` (izoh ko‘rinmasa — uning boshigacha suriladi; ko‘rinsa — qimirlamaydi; reduced motion — sakrab). `learn_screens.dart`, `daily_screens.dart`. Test: `answer_feedback_reveal_test.dart` | Tuzatildi |
| 3 | Sahifa sarlavhalari (umumiy `LgPage`) | ru 360 ×1.3: **«Конфиденциальност / ь и данные»**, «…цитруллинированному» — uzun so‘z o‘rtasidan bo‘linadi. Sabab: `FitLongWordText` pastki chegarasi masshtabdan oldin qo‘llanardi. | O‘rta | `lib/app/widgets/lg_page.dart`: chegara ko‘rinadigan o‘lchamga qo‘llanadi. **Umumiy vidjet** — Lab tabidagi sarlavhalarga ham ta’sir qiladi (faqat yaxshilanish). Test: `title_word_break_test.dart` (26 yo‘l × 3 til × 3 o‘lcham) | Tuzatildi |
| 4 | Profil → Yordam va aloqa; Aloqa va shikoyat | Do‘kon buildida reklama yo‘q (D-58), lekin matnlar «Savol, **reklama**, xato…», «email (shikoyat, **reklama**…)», «nomaqbul **reklama** haqida yozing», xat shablonida «reklama bergan firma» — chalg‘itadi. | Past | ARB (uz/ru/en): `contactRowSub`, `helpIntro`, `contactReportBody`, `contactReportHint`, `contactMailBodyReport` — reklama so‘zisiz; hamkor buildidagi «Reklama» bo‘limi (`contactAd*`) o‘zgarmadi. Test: `partner_ads_flag_test.dart :: do‘kon build: yordam/aloqa matnlarida reklama so‘zi yo‘q` | Tuzatildi |
| 5 | Kutubxona → Oflayn paketlar | Katalogdagi sinov paketi izohi: «Ichida asosiy paketdagi bitta **draft** kartaning nusxasi» (ru «черновой», en «draft») — D-65 ga zid. | Past | `packs/index.json` va generator `tool/build_pack_catalog.dart`: «bitta kartaning nusxasi». Test: `no_draft_wording_test.dart :: paketlar katalogi …`. **Eslatma:** katalog GitHub `main` dan o‘qiladi — merge qilingach ilovada yangilanadi, deploy shart emas | Tuzatildi |
| 6 | Toifa mashqi | Xuddi 2-banddagi muammo (javobdan keyin izoh pastda qoladi, 360×640 ×1.3). | O‘rta | Tuzatish tayyorlangan edi, lekin Toifa boshqa agentga o‘tkazilgani uchun **qaytarib olindi**. Toifa agenti `RevealOnMount` ni `toifa_screens.dart` dagi ikki `LgNotice` (mashq va xatolar ustida ishlash) atrofiga qo‘yishi mumkin | Topshirildi |
| 7 | Profil → Maxfiylik; «Foydalanish shartlari» | Ro‘yxatdan o‘tishda «shartlar va **maxfiylik siyosatini** qabul qilaman» belgisi bor, lekin shartlar sahifasida va Profil → Maxfiylik sahifasida siyosatning o‘ziga havola yo‘q (faqat Aloqa ichida). | O‘rta | Ikkala sahifaga «Maxfiylik siyosati» qatori (`Contact.privacyPolicyUrl`, mavjud ARB kalitlari). Test: `contact_screen_test.dart :: audit: /profile/privacy …`, `audit: /terms …`; qorovul: `product_policy_guard_test.dart` | Tuzatildi |
| 8 | «Foydalanish shartlari» | Matn: «Yakuniy shartlar … nashrdan oldin tayyorlanadi»; Profil → Maxfiylik: «Yakuniy matn tayyorlanadi». Ilova TestFlight’da, foydalanuvchi shartlarni qabul qiladi, lekin shartlar matni yo‘q. | Yuqori | Huquqiy matnni o‘zimiz yozmaymiz — **egasi savoli** (Q1) | Ochiq |
| 9 | Umumiy qidiruv (`/home/search`) | Maydon ichidagi maslahat «Tahlil, apparat yoki mavzu qidirish» 390 px da ham «…» bilan qirqiladi (bosh sahifa kartasida 2 qatorda to‘liq). | Past | `SearchBox` Lab tabida ham ishlatiladi — tegilmadi. Taklif: qidiruv sahifasida qisqaroq maslahat yoki `hintMaxLines: 2` | Ochiq |
| 10 | Toifa / izohli test (mashq rejimi) | Savol ekranlarida suzuvchi pastki menyu 640 px da C/D variantni yopadi (surilsa ko‘rinadi). | Past | Dizayn qarori (menyu doim ko‘rinadi); o‘zgartirilmadi | Ma’lumot |
| 11 | Guruhlar (server xatosi) | `myAccess` tarmoq xatosida ustoz sifatida ro‘yxatdan o‘tgan foydalanuvchiga «Guruh yaratish» ekrani yana «Ustoz sifatida ro‘yxatdan o‘tish»ni ko‘rsatadi (eski holat). Boshqa barcha ro‘yxat ekranlari xatoda «Internetga ulanib bo‘lmadi / Bajarib bo‘lmadi» + «Qayta urinish» beradi, cheksiz spinner yo‘q. | Past | Faqat ma’lumot (keyingi ochilishda tuzaladi) | Ma’lumot |
| 12 | Katta ekran (topshiriq board) | Server xatosida ham «Ekranni gorizontal holatga aylantiraymizmi?» so‘rovi chiqadi. | Past | Sinf test oqimi boshqa agentda — tegilmadi | Topshirildi |
| 13 | Ilmiy ish maydoni / Dars rejasi | «Qoralamani saqlash», «Qoralama avtomatik saqlanadi» — foydalanuvchining o‘z qoralamasi, kontent holati emas (`no_draft_wording_test` da ruxsat etilgan). | — | O‘zgarishsiz | To‘g‘ri |
| 14 | Kutubxona → kitoblar, manbalar | uz/en interfeysda kirill nomlar (ruscha kitoblar, bibliografiya) — asl nom saqlanishi to‘g‘ri. | — | — | To‘g‘ri |
| 15 | Guruhga qo‘shilish (QR/kod) | Mehmon (hisobsiz) foydalanuvchiga kod/QR bilan qo‘shilish va guruh ochish yopiq — avval kirish so‘raladi (`ClassesGate`). Talabalar ro‘yxatdan o‘tgan bo‘lishi talabi bajariladi. | — | Mavjud test: `classes_flow_test.dart :: hisobsiz: kirish taklifi…` | To‘g‘ri |
| 16 | Hamma tablar | Pro/obuna/to‘lov, reklama kartalari (do‘kon build) — topilmadi. | — | Mavjud D-58 qorovullari | To‘g‘ri |
| 17 | Admin (11 ekran) | 360×640 ×1.3, uz/ru/en — overflow va qirqilgan matn yo‘q. | — | — | To‘g‘ri |

## Tibbiy mazmun — tekshirilgan chegaralar

Manbaga qarab solishtirildi (manba ID va sahifa bo‘limi kartada bor):

| Analit | Chegara | Manba | Natija |
|---|---|---|---|
| Och qoringa glyukoza | prediabet 100–125, diabet ≥126 mg/dL; JSST IFG 110–125 | NIDDK; WHO/IDF 2006 | Mos |
| HbA1c | 5,7–6,4 %; ≥6,5 % | NIDDK, ADA 2025 | Mos |
| OGTT 2 soat | 140–199; ≥200 mg/dL | NIDDK | Mos |
| eGFR | <60; <15 mL/min/1,73 m² | NIDDK | Mos |
| Siydik ACR | ≥30; 30–300; ≥300 mg/g | NIDDK | Mos |
| Ferritin | <30 / <10 µg/L (ODS); ≤15 (CDC 1998); <15 va infeksiyada <70 (WHO 2020) | ODS, CDC, WHO | Mos |
| Transferrin to‘yinganligi | <16 % | CDC 1998 | Mos |
| B12 / MMA / folat | <200 pg/mL; 150–399 → MMA; MMA >0,271 µmol/L; folat >3 ng/mL, eritrotsit folati >140 ng/mL | NHLBI, ODS | Mos |
| Gemoglobin (anemiya) | 105/110/115/120/120/130 g/L; homiladorlik 110/105/110 | WHO 2024 | Mos |
| Gemofiliya omil faolligi | 5–40 %, 1–5 %, <1 % | CDC | Mos |
| Trombotsitlar | <150 000, >450 000; 100–150 / 50–100 / <50 / <20 ming/µL | NHLBI | Q2 ga qarang |

«Draft/Qoralama» yozuvlari kontentda ko‘rsatilmaydi (paket ichidagi `status: draft` maydoni
UI ga chiqmaydi, D-65). Hech bir tibbiy matn o‘zgartirilmadi.

## Egasiga savollar

* **Q1 (yuqori).** «Foydalanish shartlari» sahifasi hali «yakuniy matn tayyorlanadi» deydi,
  ammo foydalanuvchi ro‘yxatdan o‘tishda shartlarni qabul qiladi. Yakuniy shartlar matnini
  (uz/ru/en) kim tayyorlaydi? Maxfiylik siyosati saytda bor; shartlar ham saytga
  (`labguide.nfcstore.uz/terms/`) chiqarilsinmi?
* **Q2.** Trombotsit tasnifidagi «Serious low <50 000» va «Severe low <20 000» bosqichlari
  NHLBI sahifasining joriy matniga aynan mosmi — sahifani mutaxassis bir marta ochib
  solishtirsin (men internetsiz tasdiqlay olmadim, o‘zgartirmadim).
* **Q3.** Oflayn paketlar sahifasida do‘kon foydalanuvchisiga «Sinov paketi» (yuklovchini
  sinash uchun, klinik paket emas) ko‘rinadi. Do‘kon buildida yashirilsinmi?
* **Q4.** Umumiy qidiruv maydoni maslahati (9-band) qisqartirilsinmi, yoki `SearchBox`
  ikki qatorli maslahatga o‘tsinmi (Lab tabiga ham ta’sir qiladi)?
* **Q5.** `CLAUDE.md` repoda yo‘q (topshiriq uni o‘qishni so‘ragan) — kerakmi?

## O‘zgargan fayllar

* `lib/features/auth/ui/language_picker_screen.dart` — ixcham rejim.
* `lib/design/widgets/reveal_on_mount.dart` (yangi), `lib/features/learn/learn_screens.dart`,
  `lib/features/daily/daily_screens.dart` — javobdan keyin izohni ko‘rsatish.
* `lib/app/widgets/lg_page.dart` — `FitLongWordText` pastki chegarasi (umumiy vidjet).
* `lib/features/profile/profile_screens.dart`, `lib/features/auth/ui/auth_screens.dart` —
  maxfiylik siyosati havolasi.
* `lib/l10n/app_{uz,ru,en}.arb` (+ `flutter gen-l10n`) — reklama so‘zisiz yordam/aloqa matnlari.
* `packs/index.json`, `tool/build_pack_catalog.dart` — paket izohi.
* Testlar: `test/widget/answer_feedback_reveal_test.dart`, `test/widget/title_word_break_test.dart`
  (yangi); `language_picker_test.dart`, `partner_ads_flag_test.dart`, `contact_screen_test.dart`,
  `test/unit/no_draft_wording_test.dart`, `test/guards/product_policy_guard_test.dart`.
* `docs/GUARDS.md` — «Tablar auditi» bo‘limi. `tool/screenshots/walk_audit_tabs_test.dart` — rasm ssenariysi.
* `cloudflare/` o‘zgarmadi — server deployi kerak emas.
