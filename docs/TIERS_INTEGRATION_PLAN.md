# Pro/Premium’ni reliz tarmog‘iga birlashtirish rejasi (avto-merge’siz)

2026-10-25. Manba: `pro/tiers-premium@531ba02` → maqsad: `fix/images-apparatus@2e787e4` (reliz). Umumiy ajdod:
`main@4b0f057`. Audit: `docs/TIERS_AUDIT_2026-10-25.md`, matritsa: `docs/TIERS_MATRIX.csv`.
Bu hujjat — reja. Hech narsa birlashtirilmagan, push/deploy qilinmagan.

## 1. Farqlar (`git diff --stat 4b0f057 <tarmoq>`)

| | `pro/tiers-premium` | `fix/images-apparatus` |
|---|---|---|
| Commit (`4b0f057..`) | 21 oddiy + 6 merge (`a4bcca7` … `1087094`) | 51 |
| Fayllar | 113, +18 373 / −232 (asosan kod/test/hujjat) | 311, +39 895 / −452 (230 ta rasm bo‘lmagan fayl) |
| Asosiy maydon | `lib/core/entitlements/*`, `cloudflare/src/{billing,trial,tiers,progrants,x509}.ts`, migratsiya 0014–0018, Pro ekranlari, ARB `pro*` (154 kalit × 3 til), 20 ta Lab/learn ekraniga `requireFeature`/`pushGated`, `router.dart` `labGate` | sxemalar, “Qanday foydalaniladi?” videolari (`lib/features/howto/*`), sxema qismlari (`schematic_parts*.dart`), ilmiy ko‘rik jadvallari, ARB (+~700 qator har tilda) |
| `cloudflare/` | 26 fayl | tegilmagan |

**Ikkala tarmoq ham o‘zgartirgan 28 fayl:** `docs/GUARDS.md`, `lib/app/app_scope.dart`, `lib/main.dart`,
`pubspec.yaml`, `site/privacy/index.html`, `test/helpers/harness.dart`, ARB ×3 + `lib/l10n/gen/*` ×4, Lab
ekranlari (bloodgroup, bloodmorph, coag, copro, cytology, differential, histology, calibration, instrument,
lab_direction, qc, spermogram, toifa, tools, urinalysis).

**Sinov birlashma (`git merge-tree --write-tree`, faqat o‘qish):** matnli ziddiyat faqat **7 faylda** — `app_{uz,ru,en}.arb`
va `lib/l10n/gen/app_localizations*.dart`. Qolgan 21 fayl avtomatik qo‘shiladi, lekin MA’NO jihatidan tekshirish kerak.

## 2. Ziddiyat maydonlari va xavflar

| Maydon | Muammo | Yechim |
|---|---|---|
| ARB (uz/ru/en) | Ikkala tarmoq ham fayl oxiriga kalit qo‘shgan → matnli ziddiyat | Kalitlar birlashmasi (ikkala to‘plam), `flutter gen-l10n`; `gen/*` qo‘lda tahrirlanmaydi |
| `product_policy_guard_test.dart` | Pro versiyasi D-58 qat’iy qorovulini (`:47-114` “ARB’da to‘lov so‘zlari yo‘q”, “xarid plaginlari yo‘q”, “/profile/purchase yo‘q”) yumshatadi; avto-merge Pro versiyasini oladi | Pro relizi qaror qilinmaguncha reliz tarmog‘ida qat’iy versiya QOLADI. Pro qo‘shilgach — Pro versiyasi + `pro_flag_default_guard_test` |
| `pubspec.yaml` | `in_app_purchase*` qo‘shiladi → Android manifestga `com.android.vending.BILLING` (plagin birlashtiradi) — bayroq o‘chiq bo‘lsa ham | Bepul reliz buildini Pro birlashmasidan OLDIN yig‘ish yoki Data safety/manifestni qayta ko‘rish |
| `router.dart` | Pro `labGate` 30+ Lab yo‘liga qo‘yadi; reliz yangi yo‘l qo‘shmagan, lekin yangi panellar (sxema qismlari, HowTo) gated sahifalar ichida bo‘lib qoladi | HowTo videolari bepul qolishi kerakmi — qaror; `lab_gate_test` ga HowTo/sxema holatlarini qo‘shish |
| Lab ekranlari (15 fayl) | Reliz `HowToButton` qo‘shgan, Pro `pushGated` — bir xil faylning turli qatorlari | Avto-merge o‘tadi; `lab_audit_*`, `howto_test`, `lab_gate_test` bilan tekshirish |
| `main.dart`, `app_scope.dart` | Ikkalasi ham servis qo‘shgan (`howToVideos`, `entitlements`) | Qo‘lda: ikkala `required` maydon ham `createServices` da bo‘lsin |
| `test/helpers/harness.dart` | Reliz: video ro‘yxati yuklanishi; Pro: deterministik kunlik seed (`ea5ef8a`) + Pro override’lar | Ikkalasini saqlash |
| `site/privacy` §10a | Pro HTML’ga qo‘lda §10a qo‘shgan; sayt `PRIVACY_POLICY.md` dan yasaladi → `check_site.py` **13 xato** (Pro/obuna/подписка so‘zlari taqiqlangan + “privacy/index.html eskirgan”). Reliz versiyasi xatosiz | Birlashmada §10a OLINMAYDI. Pro yoqilganda: matn `docs/store/PRIVACY_POLICY.md` ga, `build_site.py`, `check_site.py` BANNED ro‘yxatini faqat §10a/obuna bo‘limi uchun ataylab o‘zgartirish (yurist tasdig‘idan keyin) |
| Do‘kon hujjatlari | `docs/store/APP_STORE.md:10`, `PLAY_CONSOLE_UPLOAD.md:18` — “to‘lov yo‘q (D-58)”; Pro tarmog‘i ularga tegmagan | Pro relizida qayta yozish: IAP ro‘yxati, App Privacy “Purchase History”/“Device ID”, Data safety, review eslatmasi |
| `DECISIONS.md` | Reliz D-70 da eski taklif narxlar ($3.99/$5.99, 30 kun); D-71…D-76 faqat Pro’da | D-71…D-76 ni ko‘chirish, D-70 ga SUPERSEDED belgisi |
| Migratsiyalar | Reliz 0013 gacha; Pro 0014–0018 (yangi fayllar) | Ziddiyat yo‘q; production’ga faqat egasi `deploy_api` bilan, avval test D1 |
| Haqiqiy bug-fix `ea5ef8a` | Pro tarmog‘ida (lazy ListView — uzun savol izohi qurilmaydi); relizda YO‘Q | Pro’dan mustaqil — alohida, hozir cherry-pick qilish mumkin (egasi qarori) |

## 3. Bosqichma-bosqich reja (avto-merge yo‘q)

**0-bosqich (hozir, Pro’siz).** Reliz `fix/images-apparatus` dan chiqadi — Pro kodi kirmaydi. Ixtiyoriy: `ea5ef8a`
ni alohida tarmoqda cherry-pick qilib, `answer_feedback_reveal_test` + to‘liq test to‘plami bilan tekshirish.

**1-bosqich: yangi tarmoq.** Reliz tasdiqlangandan keyin `pro/integrate` ni reliz HEAD’idan ochish. Eski commitlarni
birma-bir cherry-pick QILMANG (0013→0014 qayta raqamlash va 30→7 kun o‘zgarishlari orasida oraliq holatlar bor) —
yakuniy holatni yo‘l bo‘yicha olish:
1. Faqat Pro’ga tegishli YANGI fayllar (ziddiyatsiz): `git checkout pro/tiers-premium -- <yo‘l>` —
   `cloudflare/src/{billing,progrants,tiers,trial,x509}.ts`, `cloudflare/migrations/0014…0018`,
   `cloudflare/test/{billing,billing_lifecycle,trial,tiers,progrants,migration_0018,x509,guards}.test.ts` +
   fixturalar, `lib/core/entitlements/*`, `lib/core/backend/pro_grants.dart`, `lib/core/build_flags.dart`,
   `lib/features/profile/{pro_gate,purchase_screen,subscription_screen}.dart`, `lib/features/admin/pro_grant_screen.dart`,
   yangi Pro testlari (`test/unit/{entitlements,plan_matrix,trial_entitlement,pro_readiness_d75,admin_grant_entitlement}_test.dart`,
   `test/widget/{entitlements_flow,lab_gate,pro_flag_off,subscription_screen,admin_pro_grant}_test.dart`,
   `test/guards/pro_flag_default_guard_test.dart`, `test/helpers/billing_fakes.dart`), `docs/PRO_*.md`,
   `docs/APPLE_REVIEW_QUESTION_DRAFT.md`.
2. Server umumiy fayllari (relizda tegilmagan — Pro holati to‘g‘ridan-to‘g‘ri): `cloudflare/src/{app,auth,context,crypto,http,social}.ts`.
3. Qo‘lda port (diff’ni o‘qib): `main.dart`, `app_scope.dart`, `router.dart`, `profile_screens.dart`,
   `admin_screens.dart`, `kv_store.dart`, `cloudflare_backend.dart`, 20 ta ekran (`requireFeature`/`pushGated`
   qatorlari), `harness.dart`, `fake_backend.dart`, `repo_registry_guard_test.dart`, `pubspec.yaml/.lock`.
4. ARB: Pro’ning `pro*` (va unga bog‘liq) kalitlarini reliz ARB’siga qo‘shish (uch tilda bir xil to‘plam), `flutter gen-l10n`.
5. OLIB TASHLANADI / kiritilmaydi: `site/privacy` §10a (sayt qorovuli), Pro versiyasidagi `product_policy_guard_test`
   (Pro yoqish qarorigacha qat’iy D-58 versiyasi qoladi — yoki bayroq-o‘chiq rejimni tekshiradigan qilib qayta yoziladi),
   `tool/screenshots/walk_pro_test.dart` (ixtiyoriy).
6. Hujjatlar: D-71…D-76 ni `DECISIONS.md` ga, D-70 ga SUPERSEDED, `GUARDS.md` qo‘lda birlashtirish.

**2-bosqich: tekshiruv (har biri `flock /tmp/flutter_test.lock` bilan).**
- `flutter analyze`; to‘liq `flutter test` (relizdagi 114 widget + 57 unit + guard testlari + Pro testlari).
- Ayniqsa: `product_policy_guard_test`, `pro_flag_default_guard_test`, `pro_flag_off_test` (bayroq o‘chiq — relizdagidek),
  `lab_gate_test`, `entitlements_flow_test`, `subscription_screen_test`, `howto_test`, `howto_video_test`,
  `schematic_parts_panel_test`, `lab_card_schematic_test`, `lab_audit_{uz,ru,en}_test`, `layout_matrix_*`, `app_map_test`.
- Server: `cd cloudflare && npx vitest run` (Pro tarmog‘ida bu auditda: 24 fayl / 332 test PASS).
- `python3 tool/site/check_site.py` (+ `--self-test`), `tool/run_guards.sh`.
- `LG_PRO_ENABLED` siz release build’da Pro yo‘qligini isbotlash (`pro_flag_off_test`) — yangi qorovul: bayroq o‘chiq
  buildda `/profile/subscription`, `/profile/purchase` yo‘llari yo‘q.

**3-bosqich: billing ishlari (hali yozilmagan).**

| # | Ish | Kim | Hajm |
|---|---|---|---|
| C1 | Talaba tasdig‘i (yoki talabani tasdiqsiz sotish) — hozir Talaba rejasi sotuvda yo‘q | dev + egasi qarori | 1–3 kun (tasdiqsiz: 0.5 kun) |
| C2 | `ProGatePolicy.gated` ni to‘ldirish (qaysi funksiya pullik) + grandfathering | egasi qarori, dev 1 kun | 1 kun |
| C3 | `assignments` ni ulash (topshiriq yaratish — `requireFeature` yo‘q) | dev | 0.5 kun |
| C4 | To‘lov oynasidagi maxfiylik havolasini `Contact.privacyPolicyUrl` ga (`billing_catalog.dart:170` GitHub) | dev | 0.1 kun |
| C5 | Ustoz reja nomini birxillashtirish (“Ustoz” vs “Ustoz Pro”), eski `proPayTierPro` | dev | 0.2 kun |
| C6 | Agar serverda ham ajratish kerak bo‘lsa: `/v1/groups` va topshiriq yo‘llariga `requireTier(teacher_panel)` (hozir faqat ilovada yopiladi) | dev | 1 kun |
| C7 | Sinov uchun Android Play Integrity: native plagin + server `decodeIntegrityToken` tekshiruvchi (`DeviceAttestationVerifier`) | dev | 3–5 kun |
| C8 | iOS sinovi (agar Apple ruxsat bersa): App Attest/DeviceCheck plagin + server | dev | 3–5 kun |
| C9 | Sandbox matritsasi (xarid, tiklash, bekor, grace, refund, boshqa hisob, oflayn) ikkala do‘konda | dev + egasi qurilmalari | 2–3 kun |
| S1 | Worker secretlari, `LG_BILLING_ENABLED`, `LG_BILLING_SANDBOX` siyosati, CI `deploy_api` ga secretlar | egasi + dev | 0.5–1 kun |
| S2 | Migratsiyalar 0014–0018: test D1 → production | egasi (`deploy_api`) | 0.5 kun |
| S3 | ASSN v2 URL (App Store Connect), RTDN Pub/Sub topik + push subscription (OIDC audience) | egasi + dev | 0.5–1 kun |
| D1 | `PRIVACY_POLICY.md` obuna/sinov bo‘limi, sayt, App Privacy, Data safety, Foydalanish shartlari, `APP_STORE.md`/`PLAY_CONSOLE_UPLOAD.md` | dev + yurist | 1–2 kun + yurist |

Integratsiyaning o‘zi (1–2-bosqich): **2–3 ish kuni**. To‘liq ishlaydigan pullik reliz (C1–C9 + S + D, Android
sinovi bilan, iOS sinovisiz): taxminan **3–4 hafta** (do‘kon tekshiruv vaqtini hisobga olmaganda).

## 4. Egasi nima qaror qilishi / tayyorlashi kerak

1. **Sinov muddati: 7 yoki 30 kun** (kod hozir 7; `trial.ts:33`, `pro_catalog.dart:131`, ARB `proPrivacyTrialNote`,
   `site/privacy` §10a, testlar `trial.test.ts:117,334,373`, `trial_entitlement_test.dart:219` — o‘zgartirish ~0.5 kun).

   | | 7 kun (hozirgi kod, D-76) | 30 kun (egasi tasavvuri, D-74/D-75 eski) |
   |---|---|---|
   | Konversiya | Tez qaror; toifa/semestr sikliga qisqa | To‘liq o‘quv/imtihon siklini qamraydi; ko‘p foydalanuvchi 30 kunda “yetarli” oladi va to‘lamaydi |
   | Suiiste’mol | Har yangi telefon/emulyator uchun foyda kichik | Har qayta urinish 1 oylik bepul Pro — attestatsiya yo‘qligida xavf yuqori |
   | Daromad yo‘qotish | Kam | Oylik reja narxining 1 oyi har foydalanuvchiga |
   | Do‘kon | Server beradigan kartasiz sinov iOS’da 3.1.1 bo‘yicha NOANIQ (muddatdan qat’i nazar) | Xuddi shunday; do‘kon-native kirish taklifi (Apple 1 oy / Play) kartani talab qiladi va avtomatik pullikka o‘tadi (egasi qoidasiga zid, D-75 #1) |
   | Ma’lumot | 24 oylik xesh saqlash ikkalasida bir xil | bir xil |

   Tavsiya (qaror emas): attestatsiya (C7) tayyor bo‘lmaguncha sinovni yoqmaslik; yoqilganda 7 kun.
2. Qaysi funksiyalar pullik (`gated`), mavjud foydalanuvchilarni saqlab qolish (grandfathering), Lab yopilishi
   (`plannedLabGate`) qachon.
3. Talaba: tasdiq usuli yoki tasdiqsiz sotish; Premium sinovi sharti (ustoz + tasdiqlangan mutaxassis — juda qattiq).
4. Mehmon xaridi: hozir taqiqlangan (D-76) — Apple 5.1.1 xavfi; Apple’ga savol (`APPLE_REVIEW_QUESTION_DRAFT.md`, yuborilmagan).
5. **App Store Connect:** Paid Applications Agreement, soliq (W-8BEN), bank; bitta obuna guruhi, 8 mahsulot
   (`uz.labguide.{student,teacher,specialist,premium}.{monthly,yearly}`), narx pog‘onalari, lokalizatsiya, review
   skrinshoti; App Store Server API kaliti (.p8, Key ID, Issuer ID); ASSN v2 URL; Family Sharing — O‘CHIQ.
6. **Play Console:** payments profile/merchant, 4 obuna (`uz.labguide.<reja>`) × 2 base plan (`monthly`/`yearly`),
   **free-trial offer YARATMASLIK**; service account (Play Developer API), RTDN Pub/Sub; UZS narx pog‘onalari.
7. Yurist: sinov xeshini 24 oy saqlash, maxfiylik siyosati/shartlar matni.
8. Pro relizi vaqti: bepul reliz do‘konlarda tasdiqlangandan keyin (D-71).
