# Qorovul (guard) testlari

Egasi talabi (2026-10-18): «Har bir qilingan ishga test qo‘ying — qorovul, qilingan narsalar
o‘zgarib/buzilib qolmasin». Quyidagi jadvalda har bir qaror yoki topshirilgan ish uni ushlab
turadigan avtomatik test bilan bog‘langan. Test yiqilsa — yo qaror ataylab o‘zgargan (unda
`docs/DECISIONS.md` ga yangi qaror va test yangilanadi), yo regressiya (tuzatiladi).

Qorovul qatlamlari:

| Qatlam | Joyi | Ishga tushirish |
|---|---|---|
| Ilova (Dart) | `test/guards/*_test.dart` + bo‘lim testlari (`test/unit`, `test/widget`) | `flutter test` |
| Server (Worker) | `cloudflare/test/guards.test.ts` + boshqa `cloudflare/test/*.test.ts` | `cd cloudflare && npm run typecheck && npm test` |
| Taqdimot eksporti | `tool/slides/test_guards.py` + `tool/slides/test_*.py` | `python3 -m unittest discover -s tool/slides -p 'test_*.py'` |
| Sayt va do‘kon havolalari | `tool/site/test_guards.py`, `tool/site/check_site.py` | `python3 tool/site/check_site.py && python3 tool/site/check_site.py --self-test && python3 -m unittest discover -s tool/site -p 'test_*.py'` |
| AI vositalari (oflayn) | `tool/ai/tests/test_guards.py` + `tool/ai/tests/test_*.py` | `python3 -m unittest discover -s tool/ai/tests` |

## Hammasini lokal ishga tushirish

```bash
tool/run_guards.sh          # hammasi: Python, flutter analyze + flutter test, Worker tsc + vitest
tool/run_guards.sh --quick  # tez: Python + faqat test/guards + Worker qorovuli
```

`FLUTTER=/yo‘l/flutter` va `PYTHON=python3.12` bilan boshqa SDK tanlanadi. Worker uchun Node.js 22
kerak (`cloudflare/node_modules` bo‘lmasa `npm ci` qilinadi).

## CI

`.github/workflows/ci.yml`, har push va PR da (`main`), shuningdek `build`, `testflight`,
`play_internal` rejimlarida:

- **`tests`** job: Python qorovullari (tool/slides — `python-pptx==1.0.2` bilan; tool/site —
  check_site, self-test, test_guards; tool/ai — oflayn testlar), so‘ng `flutter analyze` va
  `flutter test` (`test/guards` shu ichida). Android va iOS buildlari `needs: tests` — qorovul
  yiqilsa build ham chiqmaydi.
- **`worker`** job: `npm run typecheck` (tsc) va `npm test` (vitest, `guards.test.ts` bilan) —
  `play_listing` dan boshqa barcha rejimlarda; `deploy_api` ham shunga bog‘liq.
- **`backend`** job: Supabase SQL/RLS qabul testlari (`tool/backend_test.sh`).

Eslatma: `docs/**` va `*.md` o‘zgarishlari CI ni ishga tushirmaydi (`paths-ignore`) — faqat
hujjat o‘zgargan commitda `docs/DECISIONS.md` qorovuli keyingi kod commitida tekshiriladi. Shuning
uchun hujjatni o‘zgartirgach `tool/run_guards.sh --quick` ni lokal ishga tushiring.

`ci.yml` ning o‘zi ham qorovul ostida: `repo_registry_guard_test.dart` → «tests job barcha qorovul
qatlamlarini ishga tushiradi» — Python qadamlari yoki worker testlari olib tashlansa test yiqiladi.

## Jadval: qaror / ish → qorovul

`fayl :: test nomi` (Dart testlari guruh nomi bilan; uzun nomlar boshi bilan).

### Mahsulot qarorlari

| Qaror / ish | Qorovul |
|---|---|
| D-58: Pro/to‘lov/obuna ilovada yo‘q — ARB matnlari | `test/guards/product_policy_guard_test.dart :: D-58 … ARB matnlarida to‘lov so‘zlari yo‘q (uz/ru/en)` (istisno: hamkor narxi, admin «Sotuvlar: 0») |
| D-58/D-71 (pro-next): proEnabled=false bo‘lsa paywall yo‘q; Pro kodi ruxsat etilgan fayllarda; marshrut va Profil qatori bayroq ortida; iOS IAP yo‘q | `product_policy_guard_test.dart :: D-58/D-71 …` (standart bayroq, Pro kodi oqib chiqmaydi, marshrut/Profil bayroq ortida, iOS) |
| D-71: Pro standart O‘CHIQ; yopish ro‘yxati bo‘sh; bepul davr o‘chiq; narxlar TAKLIF; eski narx/sinov yo‘q | `test/guards/pro_flag_default_guard_test.dart`; `test/widget/pro_flag_off_test.dart` |
| D-71: billing yo‘llari LG_BILLING_ENABLED bo‘lmasa 404 | `cloudflare/test/guards.test.ts :: qorovul: billing inert` |
| D-74: sinov va `/v1/pro/*` yo‘llari bayroqsiz 404; bayroq bilan attestatsiyasiz 503; Talaba rejasi ustoz panelini ochmaydi; sinov bir telefonga bir marta | `cloudflare/test/guards.test.ts`, `cloudflare/test/trial.test.ts`, `cloudflare/test/tiers.test.ts` |
| D-74: “Obuna” qatori va `/profile/subscription` faqat `BuildFlags.proEnabled`; matritsa server bilan bir xil | `product_policy_guard_test.dart`, `test/widget/subscription_screen_test.dart`, `test/unit/plan_matrix_test.dart` |
| D-58: serverda billing yo‘llari yo‘q, `/v1/me` `plan` bermaydi | `cloudflare/test/guards.test.ts :: D-58: Pro / to‘lov / obuna yo‘llari yo‘q`, `D-58: /v1/me tarifni (plan) bermaydi` |
| D-58: saytda to‘lov so‘zlari yo‘q | `tool/site/check_site.py` (BANNED), `tool/site/test_guards.py :: test_no_payment_words_on_site` |
| Hamkor reklamasi o‘chiq (LG_PARTNER_ADS): kod standarti | `product_policy_guard_test.dart :: standart build: bayroq o‘chiq, release buildda o‘zgarmas`; `test/widget/partner_ads_flag_test.dart :: do‘kon build: hech qayerda reklama/hamkor UI yo‘q` |
| Hamkor reklamasi o‘chiq: har CI buildida `LG_PARTNER_ADS='false'` | `test/guards/repo_registry_guard_test.dart :: hamkor reklamasi har bir CI buildida o‘chiq (LG_PARTNER_ADS)` (apk, aab, ios, ipa, config-only) |
| «Qoralama / tekshirilmagan» yozuvlari yo‘q (D-65) | `test/unit/no_draft_wording_test.dart` (o‘zgarmagan); `learning_guard_test.dart :: har deck fayli status: sourced`; `tool/slides/test_guards.py :: test_export_writes_sourced_status`, `test_deck_files_sourced` |
| «Manbalar» paneli har Lab bo‘limida, muallif + yil (D-65) | `test/guards/medical_guard_test.dart :: D-65: har Lab bo‘limida "Manbalar" paneli — muallif va yil` (siydik, spermogramma, qon guruhi, gistologiya, qon morfologiyasi, koagulogramma, koprologiya, sitologiya ×2, jadvallar); yilsiz veb-sahifalar ro‘yxati `_undatedWebPages` da; `no_draft_wording_test.dart :: shortCitation …` |
| Maxfiylik havolasi `https://labguide.nfcstore.uz/privacy/` | `product_policy_guard_test.dart :: maxfiylik siyosati havolasi — labguide.nfcstore.uz/privacy/`; `tool/site/test_guards.py :: test_privacy_url_matches_app`, `test_store_docs_use_same_host` |
| Sayt sahifalari (bosh, privacy, delete-account, j) va check_site | `tool/site/test_guards.py :: test_pages_exist`, `test_check_site_passes`, `test_check_site_self_test`; CI: `check_site.py` + `--self-test` |
| D-64: mavzu — Klassik standart, Ivory bor | `product_policy_guard_test.dart :: Klassik standart, Ivory mavjud`; `test/widget/theme_test.dart :: default is Classic; …`, `Ivory palette …` |
| Hisobni o‘chirish (Apple 5.1.1(v)) | `product_policy_guard_test.dart :: hisobni o‘chirish ilovada bor`; `guards.test.ts :: egasi qarorlari bilan qo‘shilgan yo‘llar mavjud` (`DELETE /v1/me`); `test/widget/social_auth_flow_test.dart :: hisobni o‘chirish va Apple` |
| D-63: admin email bo‘yicha hisobni o‘chiradi | `guards.test.ts :: egasi qarorlari bilan qo‘shilgan yo‘llar mavjud` (`POST /v1/admin/accounts/delete`); `cloudflare/test/adminconsole.test.ts :: aniq email + tasdiq (id) → …` |
| ADMIN_EMAILS bo‘sh — egasi emaili (fallback) | `guards.test.ts :: ikkala secret bo‘sh — egasi emaili (standart)`, `ADMIN_EMAILS ustun, keyin LG_ADMIN_EMAILS` |

### Hamjamiyat (D-62, Apple 1.2)

| Qaror / ish | Qorovul |
|---|---|
| So‘z filtri (server) | `guards.test.ts :: ro‘yxat bo‘sh emas va filtr ishlaydi; tibbiy so‘zlar o‘tadi`, `haqoratli savol — 400 abusive_language`; batafsil — `cloudflare/test/moderation.test.ts` |
| Filtr xatosi ilovada tushunarli matn | `product_policy_guard_test.dart :: so‘z filtri xatosi tushunarli matnga aylanadi`; `test/widget/community_test.dart :: server so'z filtri xatosi …` |
| Bloklash (server + ilova) | `guards.test.ts :: egasi qarorlari …` (`/v1/community/blocks` GET/POST/DELETE); `community.test.ts :: bloklash: …`; `community_test.dart :: 1.2: foydalanuvchini bloklash` |
| NCII taqiqi qoidalar matnida (`cmRulesC2`) | `product_policy_guard_test.dart :: qoidalarda NCII (intim rasmlar) taqiqi — uch tilda` |

### Kirish (D-56)

| Qaror / ish | Qorovul |
|---|---|
| Apple tugmasi Google’dan oldin | `test/unit/social_auth_test.dart :: server yoqqan va qurilma qo‘llaydigan tugmalar; Apple birinchi`; `social_auth_flow_test.dart :: ikkala tugma: Apple birinchi, …` |
| CI: Sign in with Apple entitlement qarori, IPA tekshiruvi, imzosiz buildda o‘chiq | `repo_registry_guard_test.dart :: Sign in with Apple: entitlement qarori va IPA tekshiruvi` |
| Google/Apple endpointlari bor (sozlanmasa 503) | `guards.test.ts :: egasi qarorlari bilan qo‘shilgan yo‘llar mavjud` |

### Toifa (D-60)

| Qaror / ish | Qorovul |
|---|---|
| Test 50 savol, bilet 5 savol, kunlik maqsad 50 / 1 bilet | `test/guards/learning_guard_test.dart :: rasmiy formatlar: test 50 savol, bilet 5 savol` |
| Mashq rejimi — xato darhol ko‘rinadi | `learning_guard_test.dart :: mashq rejimi bor: …`; `test/widget/toifa_daily_flow_test.dart` |
| Shifokor/talabaga toifa yopiq (audit 17-okt, #1) | `test/widget/toifa_test.dart` (`AppRole.doctor, AppRole.student`) |

### Ma’ruza va mavzu testlari (D-59, D-66)

| Qaror / ish | Qorovul |
|---|---|
| 16:9 kanvas 1280×720 (ilova = eksport) | `learning_guard_test.dart :: 16:9 kanvas — 1280×720`; `tool/slides/test_guards.py :: test_canvas_matches_app` |
| Decklar soni kamaymaydi (98 kun + 27 protokol, 372 fayl) | `learning_guard_test.dart :: decklar soni kamaymaydi`, `har deck fayli status: sourced`; `tool/slides/test_guards.py :: test_index_counts`, `test_deck_files_sourced` |
| To‘liq ekranda gorizontal holat so‘rovi | `learning_guard_test.dart :: to‘liq ekran: gorizontal holat so‘rovi …`; `test/widget/lecture_presentation_test.dart :: to‘liq ekran: so‘raydi → Ha → gorizontal; …` |
| Har dekali mavzuda ≥ 10 tekshirilgan savol (istisno: d001; protokollar — mavzusiz) | `learning_guard_test.dart :: har dekali mavzu: ≥ 10 …`, `kunlik decklarning test hovuzi ≥ 10; …`, `istisnolar hali haqiqiy`; `test/unit/topic_test_coverage_test.dart` (hujjat bilan moslik) |
| Deck matnidan olingan savollar kuzatiladi (`derived_from`) | `learning_guard_test.dart :: deck matnidan olingan savollar kuzatiladi`; `test/unit/derived_quiz_test.dart` |

### Sinf (ustoz–talaba)

| Qaror / ish | Qorovul |
|---|---|
| QR havola formati `labguide.nfcstore.uz/j/?c=KOD[&a=TEST]` | `test/guards/classroom_guard_test.dart :: format: …`; `test/unit/invite_link_test.dart` |
| Havoladan/matndan kodni ajratish | `classroom_guard_test.dart :: kod ajratiladi: sayt, ilova havolasi, xom kod, taklif matni`, `sayt sahifasi site/j/ …`; `tool/site/test_guards.py :: test_join_page_opens_app` |
| Android: `labguide://app/j` intent-filter (QR → «Ilovada ochish») | `classroom_guard_test.dart :: Android: labguide://app/j intent-filter saqlanadi` |
| iOS: Info.plist da `labguide` URL sxemasi | `classroom_guard_test.dart :: iOS: Info.plist da "labguide" URL sxemasi saqlanadi` |
| CI (iOS): Google sxemasi mavjud `CFBundleURLTypes` oxiriga qo‘shiladi (shartsiz `Add … array` yo‘q), so‘ng ikkala sxema tekshiriladi | `classroom_guard_test.dart :: ci.yml: Google (iOS) sxemasi mavjud CFBundleURLTypes ga qo‘shiladi …` |
| D-66 variant tanlovi: umumiy vektorlar (Dart = TS) | `classroom_guard_test.dart :: umumiy vektorlar o‘chirilmagan va Dart tanlovi mos`; `test/unit/variant_draw_test.dart`; `cloudflare/test/variants.test.ts` |
| «Muddat tugagach» — javoblar yashiriladi | `classroom_guard_test.dart :: "muddat tugagach": server correct: null …`; `cloudflare/test/groups.test.ts :: after_due: …`; `variants.test.ts :: after_due: …` |
| «Katta ekran» faqat taxallus / «Talaba NN» | `classroom_guard_test.dart :: Katta ekran: faqat taxallus yoki "Talaba NN"; ustoz va email yo‘q`; `groups.test.ts :: a'zo ismi: taxallus yoki 'Talaba NN'; …` |
| D-68 ilova ichidagi QR skaner: qo‘shilish ekranida tugma (qo‘llansa), plagin faqat `qr_scanner.dart` da (interfeys ortida), Android `CAMERA` + kamera majburiy emas, iOS `NSCameraUsageDescription` (uz/ru/en) QR ni tilga oladi, deployment target ≥ 12.0 | `classroom_guard_test.dart :: Ilova ichidagi QR skaner (D-68) …`; `test/widget/qr_scan_test.dart`; `test/unit/invite_link_test.dart :: skanerlangan QR matni` |

### Test va quiz bo‘limlari — haqiqiy asset’lar bilan (2026-10-18)

Saboq: soxta paketli testlar deck matnidan olingan savollar indeksga kirmay qolganini
ushlamagan (iPhone’da «savol to‘plamda yo‘q»). Quyidagi qorovullar faqat ilova bilan keladigan
fayllarni o‘qiydi (`pack.json`, `curriculum.json`, `assets/toifa/*.json`, `index_v2.json`) va
**har bir** tayyor deck / savol bo‘yicha yuradi (namuna emas). Batafsil:
`docs/AUDIT_2026-10-18_TESTS.md`.

| Qaror / ish | Qorovul |
|---|---|
| Deck matnidan olingan savollar topshiriq indeksida (bbe5529) | `test/guards/class_question_index_guard_test.dart`; `test/guards/topic_tests_all_decks_guard_test.dart :: har tayyor deck, har savol: ekranda topiladi …` |
| Mavzu testi: tayyor decklar ≥ 142, «tayyorlanmoqda» faqat ro‘yxatdagilar (d001) | `topic_tests_all_decks_guard_test.dart :: decklar holati …` |
| Mavzu testi sessiyasi (drawTopicTest + buildTopicTestSession): har savol chiqadi, tartib/kalit/ball, xatolarni takrorlash | `topic_tests_all_decks_guard_test.dart :: sessiya ilovadagidek quriladi …` |
| «Slaydni ko‘rish» — slayd deck ichida (uz/ru/en) | `topic_tests_all_decks_guard_test.dart :: “Slaydni ko‘rish” …` |
| Natija qayta ochilgandan keyin saqlanadi (har deck) | `topic_tests_all_decks_guard_test.dart :: natija qayta ishga tushirishdan keyin saqlanadi …`; `test/widget/topic_test_real_decks_test.dart` (iPhone, d040/d118/d048) |
| Sinf: id/kalit/sarlavha/mavzu server qoidalariga mos (qoidalar `cloudflare/src/groups.ts` dan o‘qiladi) | `test/guards/classroom_real_assets_guard_test.dart :: har tayyor deck: id, kalit, sarlavha …`, `server qoidalari o‘qildi …` |
| Sinf: ustoz, «Talaba ko‘rinishida sinash», talaba, katta ekran, natijalar qidiruvi har savolni topadi | `classroom_real_assets_guard_test.dart :: har tayyor deck, har savol: ustoz, …`; `test/widget/classroom_real_decks_test.dart` |
| Sinf: oddiy va variantli rejimda server balli = ilova kaliti (umumiy vektor juftlari) | `classroom_real_assets_guard_test.dart :: oddiy rejim …`, `variantli rejim …`; `cloudflare/test/real_decks.test.ts` (fixture `cloudflare/test/real_deck_assignments.json`, Dart qorovuli bilan sinxron) |
| Jadvaldagi mavzu testi sarlavhasi ≤ 120 (tuzatish) | `classroom_real_assets_guard_test.dart :: dars jadvalidagi mavzu testi …` |
| Katta ekran toifa banki yuklanmagan holda ochilsa ham savol matni (tuzatish) | `test/widget/classroom_real_decks_test.dart :: katta ekran ilova tiklanganda …` |
| Toifa: har savol — kalit oralig‘i, takrorsiz id/raqam, bo‘sh variant yo‘q, ru/en; takror matn faqat ma’lum juftlar | `test/guards/toifa_real_assets_guard_test.dart` |
| Toifa: 50 savollik test (imtihon/mashq), qayta ochilganda davom, kunlik hisob va seriya; bilet (5 savol, yozuvsiz) | `toifa_real_assets_guard_test.dart`; `test/widget/toifa_iphone_real_test.dart` (iPhone) |
| O‘rganish → Mashq, Imtihon, toifa mavzulari, kunlik savollar: har mavzu savol beradi, har savol topiladi | `test/guards/quiz_modes_real_assets_guard_test.dart` |
| Toifa mashqi, mavzu mashqi va «Xatolar ustida ishlash»: javob izohi kichik ekranda ko‘rinadigan joyga suriladi (RevealOnMount) | `test/widget/toifa_feedback_reveal_test.dart` (360×640 ×1.3, iOS; katta ekranda surilmaydi) |

### Tablar auditi (2026-10-18, `docs/AUDIT_2026-10-18_TABS.md`)

| Qaror / ish | Qorovul |
|---|---|
| Til tanlash: kichik telefonda uchala til (O‘zbekcha ham) surmasdan ko‘rinadi | `test/widget/language_picker_test.dart :: audit: all three languages visible without scrolling …`, `audit: iPhone 390×844 keeps the logo` |
| Javobdan keyin izoh avtomatik ko‘rinadi (izohli test, kunlik savollar) | `test/widget/answer_feedback_reveal_test.dart` (360×640 ×1.3, iOS; katta ekranda surilmaydi) |
| Sarlavhadagi uzun so‘z o‘rtasidan bo‘linmaydi (`FitLongWordText`) | `test/widget/title_word_break_test.dart` (uz/ru/en × 360/320 ×1.3, 390) |
| D-58: do‘kon buildida yordam/aloqa matnlarida «reklama» yo‘q | `test/widget/partner_ads_flag_test.dart :: do‘kon build: yordam/aloqa matnlarida reklama so‘zi yo‘q` |
| D-65: paketlar katalogida «draft/черновой» yo‘q | `test/unit/no_draft_wording_test.dart :: paketlar katalogi (packs/index.json) …` |
| Maxfiylik siyosati havolasi Profil → Maxfiylik va «Foydalanish shartlari»da | `product_policy_guard_test.dart :: maxfiylik siyosati havolasi …`; `test/widget/contact_screen_test.dart :: audit: /profile/privacy …`, `audit: /terms …` |

### Tibbiy tuzatishlar

`docs/AUDIT_2026-10-18_MEDICAL_REVIEW.md`:

| # | Tuzatish | Qorovul |
|---|---|---|
| 1 | Trombotsit/eritrotsit nisbati (Adewoyin 2014) | `test/widget/bloodmorph_test.dart :: tibbiy ko‘rib chiqish 2026-10-18: trombotsit/eritrotsit nisbati`; `medical_guard_test.dart :: #1 trombotsit …` |
| 2 | Namuna transfuziyadan **keyin** 3 kun | `test/widget/bloodgroup_test.dart :: tibbiy ko‘rib chiqish 2026-10-18: namuna transfuziyadan keyin saqlanadi` |
| 3 | Gonokokk Gram surtmasi (CDC 2021) | `test/widget/cytology_test.dart :: tibbiy ko‘rib chiqish 2026-10-18: gonokokk va Parij tizimi` |
| 4 | Parij tizimi 2.0 — Non-urothelial | `cytology_test.dart :: … gonokokk va Parij tizimi` |
| 5 | LFB — asosan miyelin | `test/widget/histology_test.dart :: tibbiy ko‘rib chiqish 2026-10-18: LFB asosan miyelin` |
| 6 | Jigar: «o‘rtacha oltita» | **yangi:** `medical_guard_test.dart :: #6 jigar: uz «o‘rtacha oltita» (oltitagacha emas)` |
| 1a | Tozalik darajasi pH raqamlari olib tashlandi | **yangi:** `medical_guard_test.dart :: 1a tozalik darajasi: manbasiz pH oraliqlari qaytmaydi` |
| 2-bosqich | AGC-FN, ruscha transfuziya atamalari, o‘zbekcha atamalar | `cytology_test.dart`, `bloodgroup_test.dart`, `histology_test.dart :: adabiyot tekshiruvi 2026-10-18: …` |

`docs/AUDIT_2026-10-17.md`:

| # | Tuzatish | Qorovul |
|---|---|---|
| 1 | Talabaga toifa yopiq | `test/widget/toifa_test.dart` |
| 2–4 | Pro olib tashlandi | D-58 qorovullari (yuqorida) |
| 5 | Tozalik darajasi mantiqi (leykotsit ko‘p → norma emas) | **yangi:** `medical_guard_test.dart :: #5 tozalik darajasi: …` (barcha 36 kombinatsiya); `cytology_test.dart :: tozalik darajasi: eng og‘ir belgi hal qiladi` |
| 7 | Gemoxromatoz: «qo‘llab-quvvatlaydi», «tasdiqlaydi» emas | **yangi:** `medical_guard_test.dart :: #7 gemoxromatoz …` |
| 8 | Android imzo faqat qo‘lda ishga tushirilganda | **yangi:** `repo_registry_guard_test.dart :: Android release imzosi faqat qo‘lda …` |
| — | Ruscha terminologiya (референтный, ммоль/л) | `test/unit/ru_terminology_test.dart` |

### Lab bo‘limi auditi (2026-10-18)

`docs/AUDIT_2026-10-18_LAB.md`:

| Qaror / ish | Qorovul |
|---|---|
| Lab tabining HAR sahifasi (≈ 360 manzil: hujayra/element/parazit/namuna, kalkulyator, apparat modeli, atlas rasmi, 46 protokol, mavjud bo‘lmagan id, QC/kalibrlash/tarix ma’lumoti bilan) 390×844 va 360×640, ×1,0/×1,3, kunduzgi/tungi, uz/ru/en — oxirigacha scroll: overflow yo‘q, cheksiz animatsiya yo‘q, ARB kaliti yo‘q, «Draft/Qoralama/null/NaN/TODO» yo‘q, ru/en da «46-b.» yo‘q | `test/widget/lab_audit_{uz,ru,en}_test.dart` (`lab_audit_matrix.dart`, manzillar — `lab_audit_routes.dart`) |
| QC: 1-2s, 1-3s, 2-2s, R-4s, 4-1s, 10x ishga tushadi va sahifalari ochiladi | `lab_audit_matrix.dart :: seedLabData` (+ `test/unit/qc_rules_test.dart`) |
| «Bog‘liq kartalar» Lab ichida (`/lab/analyte/:id`), orqaga — bo‘limga (D-03); protokol taqdimoti yopilganda — Lab bo‘limiga | `test/widget/lab_audit_nav_test.dart` |
| Uzun Lab sahifalari: scroll joyida (iOS), bounce oxirga, oxirgi kontent menyu ustida; tab almashganda qiymat/sanoq saqlanadi | `test/widget/lab_audit_scroll_state_test.dart` |
| Sitrat: `NaN/Infinity/1e400` → xato; standart hajm tilning o‘nlik belgisida; kalibrlash: cheksiz/manfiy qiymat rad, saqlash xatosi tarjima qilingan; koprologiya bet raqami tilda | `test/widget/lab_audit_fixes_test.dart :: #1 … #5` |

### Reyestrlar va til

| Qaror / ish | Qorovul |
|---|---|
| `docs/DECISIONS.md` raqamlari takrorsiz, D-01…D-66 uzilishsiz, asosiy qarorlar o‘chirilmaydi | `repo_registry_guard_test.dart :: qaror raqamlari takrorlanmaydi`, `D-01 … oxirgisigacha uzilishsiz; …`, `asosiy egasi qarorlari matnda turibdi` |
| Migratsiyalar: D1 `NNNN_` takrorsiz, uzilishsiz (0007 — olib tashlangan billing, band) | `repo_registry_guard_test.dart :: Cloudflare D1: …` |
| Migratsiyalar: Supabase vaqt belgisi takrorsiz | `repo_registry_guard_test.dart :: Supabase: 14 xonali vaqt belgisi, takrorsiz` |
| ARB kalitlari uz = ru = en | `test/unit/arb_parity_test.dart`; `repo_registry_guard_test.dart :: uz/ru/en kalitlari bir xil` |
| uz/en ARB da kirill harfi yo‘q | `repo_registry_guard_test.dart :: uz va en qiymatlarida kirill harfi yo‘q` |
| D-55: AI vazifalari faqat qo‘lda, standart `dry_run`, byudjet chegarasi, natija main’ga emas | `tool/ai/tests/test_guards.py :: test_only_manual_trigger`, `test_dry_run_default_true`, `test_budget_caps`, `test_main_branch_only_and_reports_not_to_main` |
| CI barcha qorovul qatlamlarini ishga tushiradi | `repo_registry_guard_test.dart :: tests job barcha qorovul qatlamlarini ishga tushiradi` |

## Yangi ish qo‘shilganda

1. Ish uchun test yozing (bo‘lim testi yoki `test/guards/` dagi tegishli faylga).
2. Shu jadvalga qator qo‘shing: qaror/ish → `fayl :: test nomi`.
3. Son chegaralari («kamaymasin»: decklar, migratsiyalar, qarorlar) — faqat ko‘paytiriladi;
   istisno ro‘yxatlari (`_topicTestExceptions`, `_undatedWebPages`, `_payAllow`) sababi bilan yoziladi
   va eskirsa — test o‘zi aytadi.
