# Test va quiz bo‘limlari auditi (2026-10-18)

Egasi: «Test bo‘limlari ilovani mashhur qiladi — hech biri haqiqiy foydalanuvchida buzilmasin.»
Bugungi saboq: TestFlight’da mavzu testida «Bu savol joriy kontent to‘plamida yo‘q» va «Bu
topshiriqdagi 10 ta savol ilovangizdagi to‘plamda yo‘q» chiqdi (sababi — `classQuestionIndex`
deck matnidan olingan savollarni o‘tkazib yuborgan; bbe5529 da tuzatilgan). Mavjud widget
testlari buni ushlamagan, chunki d013 kabi deck’da derived savol yo‘q edi yoki soxta paket
ishlatilgan. Shuning uchun bu auditdagi **barcha** yangi testlar faqat ilova bilan birga
keladigan haqiqiy fayllarni o‘qiydi:

* `assets/content/core/pack.json` (479 savol, shundan 306 tasi deck matnidan olingan),
* `assets/curriculum/curriculum.json`,
* `assets/toifa/kdl_tests.json` (488 test), `assets/toifa/kdl_oral.json` (289 og‘zaki),
* `assets/lectures/index_v2.json` (189 deck: 142 tasida test tayyor, 1 tasi «tayyorlanmoqda»
  (d001), 46 tasi mavzusiz amaliy protokol — tugma yo‘q).

Qorovullar **namuna emas, har bir tayyor deck va har bir savol** bo‘yicha yuradi.

## 1. Topilgan va tuzatilgan xatolar

### 1.1 Jadvaldagi mavzu testini ustoz boshlay olmasdi (10 mavzu, server 400)

* **Qayerda:** Guruh → dars jadvali → mavzu → «Testni boshlash»
  (`lib/features/classroom/classroom_screens.dart`).
* **Sabab:** sarlavha `Test: <mavzu nomi>` qisqartirilmasdan yuborilardi; server (`groups.ts`,
  `str(body.title, 3, 120)`) 120 belgidan uzunini `400 invalid_title` bilan rad etadi.
  Haqiqiy o‘quv dasturida 10 ta mavzu nomi uzun: d012-L/P, d035-P, d040-P (ru/en), d041-P
  (ru/en), d054-P, d075-L/P, d116-L — sarlavha 122–164 belgi. Ustoz «Xatolik» ko‘rardi va
  shu mavzuga test bera olmasdi. (Taqdimotdan «Guruhga topshirish» yo‘lida qisqartirish bor
  edi — shuning uchun u ishlardi.)
* **Tuzatish:** umumiy `fitAssignmentTitle()` (`topic_questions.dart`, chegara
  `kAssignmentTitleMax = 120`) — ikkala yo‘l ham shundan foydalanadi
  (`classroomTestTitle()`, `topicAssignmentTitle()`).
* **Regressiya testi:** `test/guards/classroom_real_assets_guard_test.dart :: dars jadvalidagi
  mavzu testi …` — har o‘quv dasturi mavzusi, uch tilda; chegara serverning o‘z faylidan
  o‘qiladi. Tuzatishsiz yiqiladi (tekshirildi).

### 1.2 «Katta ekran»da toifa savollari «to‘plamda yo‘q» ko‘rinishi mumkin edi

* **Qayerda:** `lib/features/classroom/board_screen.dart` — yakunlangan testda «Eng qiyin
  savollar».
* **Sabab:** katta ekran savol matnini `classQuestionIndex(pack, toifa.bank)` dan oladi, lekin
  toifa bankini o‘zi yuklamasdi. Odatda ustoz topshiriq sahifasidan kiradi (u bankni yuklaydi),
  ammo ilova tizim tomonidan tiklanganda (router `restorationScopeId` yoqiq; iOS fonda
  ilovani yopsa) katta ekran to‘g‘ridan-to‘g‘ri ochiladi — bank `null`, toifa savollari
  o‘rnida «Bu savol joriy kontent to‘plamida yo‘q» chiqardi (bugungi iPhone xatosi bilan bir xil
  ko‘rinish).
* **Tuzatish:** katta ekran ochilganda `toifa.ensureLoaded()`; jadval paket/bank yuklanishini
  tinglaydi (`ListenableBuilder`).
* **Regressiya testi:** `test/widget/classroom_real_decks_test.dart :: katta ekran ilova
  tiklanganda to‘g‘ridan-to‘g‘ri ochilsa …` (`makeServices(loadToifa: false)`). Tuzatishsiz
  yiqiladi (tekshirildi).

### 1.3 Toifa mashqida javob izohi kichik ekranda ko‘rinmasdi

* **Qayerda:** `lib/features/toifa/toifa_screens.dart` — 50 savollik mashq rejimi
  (`ToifaDrillScreen`) va mavzu bo‘yicha mashq / «Xatolar ustida ishlash»
  (`ToifaPracticeScreen`).
* **Sabab:** 360×640, ×1.3 da variant bosilgach «To‘g‘ri / xato» izohi va «Keyingi» tugmasi
  ekrandan pastda qolardi — foydalanuvchi natijani ko‘rmasdan qo‘lda surishi kerak edi.
* **Tuzatish:** ikkala izoh `RevealOnMount` (04e0eda, tablar auditi) bilan o‘raldi; katta
  ekranda ro‘yxat qimirlamaydi.
* **Regressiya testi:** `test/widget/toifa_feedback_reveal_test.dart` (iOS, 360×640 ×1.3: mashq,
  aralash mashq, xatolar; 390×2400 — surilmaydi). Tuzatishsiz yiqiladi (tekshirildi).

### 1.4 Kichik o‘zgarishlar (xulq o‘zgarmagan)

* `topicAssignmentTitle()` — «Guruhga topshirish» sarlavhasi alohida funksiyaga chiqarildi
  (uch tilda sinash uchun).
* `test/helpers/harness.dart`: `makeServices(loadToifa: false)` — ilova sovuq ochilgandek.

## 2. Qo‘shilgan qorovullar (`test/guards/`)

| Fayl | Nima tekshiriladi |
|---|---|
| `topic_tests_all_decks_guard_test.dart` | Har tayyor deck (142) va har savol (~2 300): `topicQuestion` ning ikkala holati (bank yuklangan — `ClassQuestionSource`, hali yuklanmagan — `PackQuestionSource`) topadi; uz/ru/en matn va variantlar; bitta kalit oralig‘ida; variantlar takrorlanmaydi. `drawTopicTest` + `buildTopicTestSession` ko‘p urug‘ bilan — hovuzning **har** savoli kamida bir marta chiqadi; tartib almashtirish, rasmiy savolda asl tartib, kalit, to‘liq/nol ball, xatolarni takrorlash. «Slaydni ko‘rish» — har savol, har til, slayd deck ichida. Natija va oxirgi sessiya yangi controller’da (ilova qayta ochilgandek) saqlanadi. Tayyor decklar ≥ 142; «tayyorlanmoqda» faqat d001. |
| `classroom_real_assets_guard_test.dart` | Server qoidalari **`cloudflare/src/groups.ts` dan o‘qiladi** (ID_RE, TOPIC_RE, MAX_POOL, ≤ 50 savol, kalit ≤ 20, sarlavha ≤ 120). Har tayyor deck: id, kalit, sarlavha (uz/ru/en), `day_id`, `deck_id`, `pool_topics` server qabul qiladi. Har savol: ustoz, «Talaba ko‘rinishida sinash», talaba testi (`_packOnly` → paket yoki aralash manba), katta ekran va natijalar qidiruvi topadi; topilgan kalit = yuborilgan kalit. Oddiy va variantli rejim: umumiy vektorlardagi (topshiriq, talaba) juftlari bilan talaba ilovadagidek `ExamSession` (aralashtirish bilan) yechadi → server balli (TS mantiqi takrorlangan) to‘g‘rida to‘liq, xatoda 0 va ilova balli bilan teng; natijalar jadvali (`tallyQuestions`). Jadvaldagi mavzu testi yo‘li ham. Worker fixture’i asset bilan sinxron. |
| `toifa_real_assets_guard_test.dart` | 488 test: id/raqam takrorsiz, kalit oralig‘ida, ≤ 1 kalit, 3–4 variant, bo‘sh variant yo‘q, uch tilda variantlar takrorlanmaydi, ru/en bor. Takror matn — faqat rasmiy ro‘yxatdagi ma’lum juftlar (139/190, 380/401). 50 savollik imtihon: asl tartib, kalit = rasmiy, hamma savol chiqadi. Mashq rejimi: darhol hisob, qayta ochilganda davom, 50 → kunlik maqsad, seriya, ertasi kun, xatolarni qayta ishlash. 289 og‘zaki: reja bor, ru/en reja qadamlari teng va bo‘sh emas; har toifa biletiga ≥ 5. Bilet: har toifa havzasi to‘liq aylanib chiqiladi, 5 ta takrorsiz, o‘rtasida qayta ochilsa davom, bilet kunlik hisobga yoziladi. |
| `quiz_modes_real_assets_guard_test.dart` | O‘rganish → Mashq: guruhlar, analit mini-testi — derived savol kirmaydi, uch tilda, kalit oralig‘ida. Imtihon (paket): har mavzu savol beradi, har savol manbadan topiladi, sessiya to‘liq ball. Toifa mavzulari. Kunlik savollar: har rol hovuzi bo‘sh emas, ustuvor mavzular mavjud. |

Worker tomoni: `cloudflare/test/real_decks.test.ts` — 142 deckning har biri uchun haqiqiy
server kodi orqali oddiy va variantli topshiriq yaratiladi (201), ikki talaba boshlaydi va
topshiradi: to‘g‘ri javoblar — to‘liq ball, xato — 0; variantli testda server bergan to‘plam =
`drawVariant`; javoblar teskari tartibda yuborilsa ham ball to‘g‘ri; ustoz kaliti = ilova
yuborgani. Real hovuzlarda variant tanlovi Worker = Dart (fixture’dagi `draws`). Fixture’ni Dart
qorovuli yozadi va tekshiradi:
`LG_WRITE_FIXTURES=1 flutter test test/guards/classroom_real_assets_guard_test.dart`.

Kalit qanday quriladi (tekshirildi): server savol bankini bilmaydi — kalitni ustoz ilovasi
yuboradi (`correct_indexes` = har savolning **asl** variant indeksi, `q.correct.single`).
Talaba ilovasi javobni ham asl indeksda yuboradi (`ExamSession.submissionAnswers`), variantli
testda — `question_ids` bilan; server o‘z to‘plami tartibiga keltiradi. Derived va toifa
savollari uchun ham shu yo‘l — ular uchun alohida server kaliti kerak emas. Toifa savollarida
variantlar aralashtirilmaydi; paket savollarida aralashtiriladi — ikkalasida ham ball to‘g‘ri.

## 3. Widget testlari (haqiqiy asset’lar)

| Fayl | Nima |
|---|---|
| `test/widget/topic_test_real_decks_test.dart` | iPhone 390×844, iOS fizikasi: d040 (derived, uz), d118 (toifa, ru), d048 (paket ko‘p, en) — 10 savolning hammasiga javob, natija 5/10, har xato uchun tahlil kartasi va «Slaydni ko‘rish» (kutilgan slaydda ochiladi), xatolarni takrorlash, so‘ng ilova qayta ochiladi (o‘sha ombor) — natija, «eng yaxshi» va ro‘yxatdagi `5/10` belgisi saqlangan. 360×640 ×1.3 — 3 deck × 3 til: savol, natija, tahlil sig‘adi. |
| `test/widget/classroom_real_decks_test.dart` | d040, d118, d048 × oddiy/variantli: ustoz ilovada topshiradi → «Talaba ko‘rinishida sinash» (har savol, ball, serverga yuborilmaydi) → talaba ilovada yechadi (server balli 6/6) → ikkinchi talaba xato → ustoz natijalari va «eng qiyin savollar» matni → katta ekran. 360×640 ×1.3 uz/ru/en: topshirish, sinash, talaba testi. Katta ekran tiklanish holati (1.2). |
| `test/widget/toifa_iphone_real_test.dart` | iPhone, iOS: mashq rejimida 50 savolning hammasi ekrandan, 25-savolda ilova qayta ochiladi, natija 40/50, kunlik maqsad va «Ertaga davom etamizmi?» taklifi. Bilet: 5 savol, yozish maydoni yo‘q, 3-savolda qayta ochilsa davom etadi, bilet kunlik hisobga yoziladi. |

Toifa bo‘limi faqat o‘zbek tili yoki UZ mintaqasida ko‘rinadi (D-60) — iPhone testi uz’da;
ru/en tarjimalarning to‘liqligi qorovulda tekshiriladi, 320 px ×1.3 uz/ru/en tartibi mavjud
`toifa_daily_flow_test.dart` da.

## 4. Kalitlar: tasodifiy tekshiruv (22 ta, `verdict: ok`)

Tekshirilgan (rasmiy kalit tibbiy jihatdan to‘g‘ri): kdl-t-032 (poykilotsitoz — shakl),
035, 039 (bronx — ko‘p qatorli kiprikli epiteliy), 069 (UTBS — transferrin), 106 (De Ritis —
virusli gepatit), 115 (aldosteron), 128 (trombotsitda tromboksan A2), 138, 147 (subklavian
kateterdan qon olinmaydi), 155, 192 (leyshmanioz — sodda hayvon), 288 (yetilish indeksi), 292,
310, 314 (mieloma — absolyut giperproteinemiya), 331 (EChT — disproteinemiya), 362 (katal —
ferment faolligi), 440, 474, 475, 486. Bundan tashqari 139/190 (endoteliyda prostasiklin).
`verdict: ok` savollarda ilovada alohida manba havolasi yo‘q — manba rasmiy ro‘yxatning o‘zi.

**Shubhali kalitlar (o‘zgartirilmadi, mutaxassis ko‘rib chiqsin):**

* **kdl-t-263** «Oqsilning biologik funksiyasi bo‘lmagan»: kalit — «Energetik». Biokimyo
  darsliklarida energetik funksiya oqsil funksiyalaridan biri sifatida keltiriladi (asosiy
  emas). Rasmiy javob mantiqi «eng kam xos» bo‘lishi mumkin, lekin savol noaniq —
  `ambiguous` belgisi va izoh qo‘shish tavsiya etiladi (manba bilan).
* **kdl-t-139 / kdl-t-190** — ro‘yxatda bir xil savol ikki marta (kalit bir xil). 50 savollik
  testga ikkalasi ham tushishi mumkin; rasmiy ro‘yxatga moslik uchun qoldirildi.
* **kdl-t-380 / kdl-t-401** — bir xil matn, variantlar boshqa; 401 kaliti allaqachon
  `disputed` (LDG; to‘g‘risi lipaza/amilaza), izohi bor.

Domlaning tekshirilmagan 529 savoli qo‘shilmadi.

## 5. O‘zgarmagan, lekin tekshirilgan

* `DeckPools` / `deckTestState`: mavzusiz 46 deck — tugma yo‘q; d001 — «tayyorlanmoqda».
* «Guruhga topshirish»: oddiy rejimda ≤ 50, variantlida hovuz ≤ 60 (id bo‘yicha tartiblangan),
  `variantTopic` server regex’i bilan bir xil.
* Talaba testi manbasi: hamma savol paketda bo‘lsa `pack` (derived ham topiladi), aks holda
  `class`; ikkalasi ham har savolni topadi.
* Toifa eslatmasi: maqsad bajarilsa reja ertadan (`syncToifa`, mavjud
  `toifa_daily_test.dart`); taklif faqat maqsad bajarilganda.

## 6. Qilinmagan / eslatmalar

* Server (`cloudflare/src`) o‘zgarmadi — **deploy kerak emas** (faqat yangi test va fixture).
* Haqiqiy iPhone’da (TestFlight) tekshirish: widget testlari iOS fizikasi va 390×844 da, lekin
  native qatlam (bildirishnoma, kamera) bu muhitda sinalmaydi.
* Toifa savollarining `verdict: ok` kalitlari uchun ilovada manba havolasi yo‘q — bu rasmiy
  ro‘yxat kaliti; kalit faqat manba aniq aytsa o‘zgartiriladi.

## 7. Natijalar

* `flutter analyze` — toza.
* `flutter test` — 1885 o‘tdi, 1 o‘tkazib yuborilgan (`~1`, avvaldan), 0 yiqilgan.
* `cloudflare`: `npx tsc --noEmit` — toza; `npx vitest run` — 16 fayl, 209 test, hammasi o‘tdi.
* `bash tool/run_guards.sh` — `--quick` rejimida o‘tdi (Python: slides 89, site 7, ai 93; `test/guards` 85; Worker qorovuli 7). To‘liq rejimning qolgan qadamlari (analyze, to‘liq `flutter test`, to‘liq vitest) alohida ishga tushirildi — yuqorida.
