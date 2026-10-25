# Ustoz Pro xaritasi: bugun bepul ↔ Pro qo‘shimchasi (2026-10-25, `paid/teacher`)

> Faqat lokal tarmoq (`paid/teacher`, `paid/feat@731629c` dan). **Push, merge, PR, build, deploy, D1 ga migratsiya —
> QILINMAGAN.** `LG_PRO_ENABLED` standart `false`: bayroq o‘chiq buildda bu yerdagi hech bir ekran, qator yoki yo‘l
> yo‘q; server `LG_BILLING_ENABLED` o‘rnatilmagan bo‘lsa barcha `/v1/teacher*`, `/v1/teacher-invites*`,
> `/v1/me/teacher-tests*` yo‘llari 404.

Egasi qarori (2026-10-25): **Ustoz Pro** (`teacher_panel`) = test yaratish, talabalarni biriktirish, guruhlar va
natijalarni boshqarish. **Bugun `main` da bor hamma narsa bepul qoladi** — Pro faqat YANGI imkoniyat qo‘shadi.
7 kunlik sinov — huquq/sinov tizimi (o‘zgartirilmadi).

## 1. Bugun bepul (o‘zgarmaydi) va Pro qo‘shimchasi — imkoniyat bo‘yicha

### 1.1 Test yaratish — `Feature.teacherTestBuilder` (`teacher_panel`)
| Bugun bepul (main) | Ustoz Pro qo‘shimchasi |
|---|---|
| Topshiriq faqat **ilovadagi** savollardan: mavzu testi (taqdimotdan “Guruhga topshirish”), umumiy test (bir nechta mavzu), variantli test (D-66), o‘quv rejasi mavzusi testi | **O‘z savollari** bilan test: sarlavha, izoh, 1–100 savol, har savolda 2–6 variant, bitta to‘g‘ri javob (kalit), ixtiyoriy izoh |
| Savollar matni o‘zgartirilmaydi | Ilovadagi savollardan **nusxa** olish (mashq savollari, toifa banki — faqat bitta to‘g‘ri javobli, kaliti bahsli bo‘lmagan), **manba saqlanadi** (`source: {bank, id}`), nusxani tahrirlash mumkin |
| — | Vaqt chegarasi (1–180 daq), o‘tish chegarasi (1–100%), **nashr etilgan / nashr etilmagan** holat, versiya (boshqa qurilmadagi tahrir ustidan yozilmaydi — `409 version_conflict`) |
| — | Serverda saqlanadi (D1 `teacher_tests`) va qurilmada keshlanadi (internetsiz ro‘yxat va test ko‘rinadi) |

### 1.2 Talabalarni biriktirish va topshirish — `Feature.teacherTestAssign` (`teacher_panel`)
| Bugun bepul (main) | Ustoz Pro qo‘shimchasi |
|---|---|
| Ustoz sifatida ro‘yxatdan o‘tish, guruh yaratish (≤ 10), a’zo ≤ 200 | — (o‘zgarmaydi) |
| 8 belgili kod / QR / havola bilan qo‘shilish (talaba o‘zi kiradi), taxallus, guruhdan chiqish, ustoz a’zoni chiqaradi, kodni yangilash, guruhni o‘chirish | **Taklifnoma**: muddati (1/7/30 kun) va foydalanish soni (1/50/200) cheklangan 12 belgili kod (`ABCD-EFGH-JKLM`, `labguide://app/ti?t=..`); talaba avval **nima ulashilishini o‘qiydi** va “Roziman” ni belgilab **o‘zi qabul qiladi** (rad etish — serverga hech narsa yozilmaydi); ustoz faol taklifnomalarni ko‘radi, nusxalaydi, bekor qiladi |
| Topshiriq butun guruhga, vaqt, muddat (yo‘q / 1 / 3 / 7 kun / sana), javoblar qachon ochilishi, ustoz yopadi, katta ekran | O‘z testini **butun guruhga yoki guruhning bitta talabasiga**; muddat (majburiy); **urinishlar soni** (1–5, UI da 1–3); **kechikish siyosati** (muddatdan keyin rad / “kechikkan” deb qabul); holatlar **assigned → started → submitted → expired**; vaqt va muddat serverda (2 daqiqa tarmoq vaqti); topshiriq — testning nusxasi (keyingi tahrir berilganni o‘zgartirmaydi) |

### 1.3 Natijalarni boshqarish — `Feature.teacherResults` (`teacher_panel`)
| Bugun bepul (main) | Ustoz Pro qo‘shimchasi |
|---|---|
| Ilova savollaridan topshiriq: talabalar jadvali (ball), o‘rtacha ball, topshirganlar soni, “Savollar bo‘yicha”, “Eng qiyin savollar” (5 ta), talaba natijasi sahifasi, jonli yangilanish, katta ekran | **O‘z testlari** bo‘yicha: talaba kesimi (holat, eng yaxshi ball, %, o‘tdi/o‘tmadi, vaqt, urinishlar, kechikkan), savol kesimi (% to‘g‘ri, variantlar taqsimoti), eng ko‘p xato qilingan savollar, o‘rtacha, o‘tganlar ulushi, o‘rtacha vaqt |
| CSV yo‘q | **CSV** (server yasaydi, emailsiz; formula in’ektsiyasidan himoya) — vaqtinchalik xotiraga nusxa (ilovadagi mavjud QC CSV mexanizmi kabi). **PDF — QURILMADI**: ilovada PDF yaratish mexanizmi yo‘q (faqat PDF o‘quvchi `pdfrx`) |
| — | Topshiriqni yopish (yangi urinish yo‘q, boshlaganlarga 2 daqiqa), o‘chirish |

### 1.4 Talaba tomoni — `Feature.teacherTests` (`learner`, Talaba Pro)
| Bugun bepul (main) | Pro qo‘shimchasi |
|---|---|
| Bepul guruh topshiriqlarini yechish (imtihon oqimi) — o‘zgarmaydi | Ustoz testlari ro‘yxati, tavsif (savollar soni, vaqt, o‘tish chegarasi, muddat, urinishlar, kechikish siyosati), **birinchi topshirishdan oldin “Natija ustozingizga ko‘rinadi”** ogohlantirishi (va tasdiq oynasida yana), oddiy yechish oqimi (savol, variantlar, oldinga/orqaga, xarita, server vaqti bo‘yicha taymer, vaqt tugasa o‘zi topshiriladi, javoblar qurilmada saqlanadi), o‘z natijasi va (urinishlar tugagach / muddat o‘tgach / yopilgach) to‘g‘ri javoblar va izohlar |

## 2. Gate qoidalari (ilova — UX; qaror — serverda)

| Amal | Ilova | Server |
|---|---|---|
| Yangi test, tahrir, saqlash | `pushGated` / `allowOrOffer(teacherTestBuilder)` | `requireTier('teacher_panel')` + `teacher_accounts` → `403 plan_required` / `tier_insufficient` / `teacher_role_required` |
| Topshirish, taklifnoma yaratish | `pushGated` / `requireFeature` / `allowOrOffer(teacherTestAssign)` | xuddi shu |
| CSV eksport | `allowOrOffer(teacherResults)` | xuddi shu |
| Talaba: YANGI urinish | `allowOrOffer(teacherTests, inProgress: …)` — testni BOSHLASHda | `requireTier('learner')` |
| Talaba: boshlangan urinishni davom ettirish va topshirish | tekshirilmaydi (`inProgress: true`) | tekshirilmaydi — obuna o‘rtada tugasa ham topshiriladi |
| O‘z testlari, topshiriqlari, natijalarini **ko‘rish**; yopish; o‘chirish | ochiq | faqat sessiya + `teacher_accounts` (D-78 §7: ma’lumot o‘chirilmaydi va yashirilmaydi) |
| Taklifnomani ko‘rish/qabul qilish (talaba) | ochiq (hisob kerak) | sessiya + aniq `consent: true` |

`ProGatePolicy.gated` = `{teacherTests, teacherTestBuilder, teacherTestAssign, teacherResults}`; har chaqiruv joyi
`test/guards/pro_flag_default_guard_test.dart` `kGateCallSites` da. Mehmon: Ustoz Pro ekranlari — “Guruhlar uchun
hisobga kiring” (xato yo‘q); `can()` — `false`. Kirish qatorlari (Guruhlar ekrani) faqat `services.teacherTests != null`
(Pro bayrog‘i + server): ustozga — “Mening testlarim”; **talabaga “Ustoz testlari” — faqat guruh a’zosi bo‘lsa** (bo‘sh
bo‘lim ko‘rsatilmaydi); hammaga — “Taklifnoma kodi”.

## 3. Maxfiylik va o‘chirish
- Ustoz faqat **hozir guruh a’zosi** (kod yoki taklifnoma bilan o‘zi qo‘shilgan) talabalar natijasini ko‘radi; email
  hech qayerda (ekran, CSV) yo‘q — taxallus yoki “Talaba NN”.
- Talaba guruhdan chiqsa yoki chiqarilsa — shu guruh topshiriqlaridagi urinishlari va unga shaxsan berilgan topshiriqlar
  **o‘chiriladi** (`groups.ts` `leaveGroup`/`removeMember` → `teacherLeaveStatements`, faqat bayroq bilan).
- Hisob o‘chirilsa (`deleteUserData`): o‘z urinishlari; ustoz bo‘lsa — testlari, topshiriqlari (boshqalarning ulardagi
  urinishlari bilan), taklifnomalari (`teacherDeleteStatements`, faqat bayroq bilan) + FK `ON DELETE CASCADE`.
  Bepul guruh o‘chirilsa — uning Ustoz testi topshiriqlari va urinishlari ham (CASCADE).
- Taklifnoma kodi xom saqlanmaydi: HMAC (qidirish) + AES-GCM (faqat egasiga qayta ko‘rsatish).

## 4. Server va baza
- Migratsiya: **`cloudflare/migrations/0020_teacher_tests.sql`** (faqat fayl; 0019 parallel `paid/srv` tarmog‘ida band —
  `0019_trial_attest_guest.sql`; shu tarmoqning o‘zida `repo_registry_guard` “uzilishsiz raqam” testi 0019 yo‘qligi
  sababli yiqiladi, `paid/srv` bilan birlashtirilgach o‘tadi): `teacher_tests`, `teacher_test_assignments`, `teacher_test_attempts` (bitta ochiq urinish —
  qisman unikal indeks), `teacher_invites`.
- Kod: `cloudflare/src/teachertests.ts` (yo‘llar `app.ts` `billingRoutes` da), `cloudflare/src/teacherdata.ts`
  (o‘chirish/tozalash), `groups.ts` va `auth.ts` dagi bayroqli qo‘shimchalar, kunlik tozalash (`scheduled`).
- Cheklovlar (`TT_LIMITS` = ilova `TeacherTestLimits`, test solishtiradi): 200 test/ustoz, 100 savol, sarlavha 3–120,
  izoh ≤ 1000, savol ≤ 1000, variant ≤ 300 (2–6, takrorsiz), izoh ≤ 1000, urinish ≤ 5, faol topshiriq ≤ 300,
  guruhga faol taklifnoma ≤ 20, foydalanish ≤ 200, muddat ≤ 30 kun; tana ≤ 512 KB (test yo‘llari).
- Limitlar: yozish 120/soat (ustoz), urinish boshlash 30/soat, taklifnoma ko‘rish/qabul 20/15 daq (hisob) va 100/soat (IP).
- Audit: `teacher_test_created/updated/deleted`, `teacher_test_assigned`, `teacher_assignment_closed/deleted`,
  `teacher_invite_created/revoked/accepted`, `teacher_results_exported`.

## 5. Ilova fayllari
- `lib/core/backend/teacher_tests.dart` (modellar, cheklovlar, interfeys), `cloudflare_teacher_tests.dart` (HTTP),
  `cloudflare_backend.dart` (`TeacherTestHost`), `lib/app/app_scope.dart` (`teacherTests`, `teacherTestCache`).
- `lib/features/teacher_pro/`: `teacher_test_screens.dart` (ro‘yxat, test, muharrir, savol oynasi, ilova banki),
  `teacher_assign_screens.dart` (topshirish, taklifnomalar), `teacher_results_screens.dart`,
  `student_teacher_tests_screens.dart` (ro‘yxat, tavsif, yechish, taklifnomani qabul qilish),
  `teacher_pro_common.dart`, `teacher_test_cache.dart`, `teacher_pro_routes.dart` (router — faqat `BuildFlags.proEnabled`).
- `lib/core/storage/kv_store.dart`: `teacherPro.tests`, `teacherPro.answers` (StoreKeys.all).
- ARB: 192 ta yangi kalit (uz/ru/en): 189 ta `tt*` va reja nomi bor 3 ta `proTt*` (mahsulot siyosati qorovuli: to‘lov/reja
  so‘zlari faqat `pro*` kalitlarida).

## 6. Qurilmagan / ochiq qarorlar
1. **PDF eksport** — ilovada PDF yaratish mexanizmi yo‘q; faqat CSV (xotiraga nusxa). Fayl sifatida ulashish
   (`share_plus` bilan `.csv`) — keyingi qadam (Talaba Pro `resultsExport` bilan birga qilish ma’qul, `paid/feat`).
2. Sayt `site/j/` taklifnoma (`?t=`) sahifasi o‘zgartirilmadi (matnlar agenti hududi): taklifnoma kod va ilova havolasi
   (`labguide://app/ti?t=..`) bilan beriladi; https havola — keyin.
3. “Faqat oldinga” (orqaga qaytmaslik) rejimi va savollarni aralashtirish — qilinmadi (topshiriq: “oddiy test oqimi”).
4. Talabani boshqa guruhga ko‘chirish, guruhlar orasida nusxa — yo‘q (bepul guruh boshqaruvi o‘zgarmadi).
5. Talaba tomoni Talaba Pro (`learner`) talab qiladi — Ustoz Pro obunachisining talabalari ham pullik rejaga muhtoj
   bo‘ladi (D-78 katalogi bo‘yicha). Egasi qaror qilishi kerak: shunday qoladimi yoki ustoz testini yechish bepulmi.
6. Production: migratsiya 0020 ni avval test D1 ga, so‘ng `LG_BILLING_ENABLED` bilan — rahbar/egasi qarori.

## 7. Testlar (2026-10-25, shu tarmoqda, haqiqiy ishga tushirish)
- Server (`cloudflare/`, repo tashqarisidagi nusxada): `tsc --noEmit` — xato yo‘q; `vitest run` — **25 fayl, 357 test PASS**
  (yangi: `test/teachertests.test.ts` — 24, `test/auth.test.ts` — +1 hisobni o‘chirish). `paid/srv` dagi
  `0019_trial_attest_guest.sql` bilan birga (nusxada) — teachertests/groups/tiers 70 PASS.
- Ilova: `flutter analyze` — xato yo‘q. `test/unit` — 930 PASS (yangi `teacher_tests_test.dart` — 14);
  `test/widget` — 117 fayl, hammasi PASS (yangi `teacher_pro_test.dart` — 30); `test/guards` + `test/integration` —
  191 PASS, 1 skip (oldindan bor), **1 FAIL: `repo_registry_guard` “migratsiya raqamlari uzilishsiz” — `[19]`**
  (0019 `paid/srv` da; shu fayl vaqtincha qo‘yilganda test o‘tdi — birlashtirilgach yo‘qoladi).
- Ataylab yangilangan eski testlar (D-78: `gated` endi bo‘sh emas): `pro_readiness_d75_test`, `subscription_screen_test`,
  `pro_flag_off_test` (bo‘sh ro‘yxat holati endi aniq `gatedFeatures: {}`).
- `python3 tool/l10n/normalize_uz_apostrophes.py --check` — 0.

