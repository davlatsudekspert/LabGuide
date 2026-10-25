# Pullik tarmoq holati: `paid/pro-premium` (2026-10-25, D-77)

> Faqat lokal tarmoq. **Push, `main` ga merge, PR, GitHub Actions, build, deploy, do‘konga yuborish, do‘kon/billing
> API chaqiruvi — QILINMAGAN.** Haqiqiy App Store / Google Play sandbox xaridi bir marta ham sinalmagan
> (NOT VERIFIED): barcha Pro testlari soxta do‘kon / soxta server / soxta attestatsiya bilan.

## 1. Nima qilindi

Egasi qarori D-77 (2026-10-25): keyingi yangilanishda **Free + Pro + Premium**, bepul sinov **faqat 7 kun**.
Do‘kon tekshiruvidagi bepul versiya (`main` `4b0f057`) va `fix/images-apparatus` (`215d3e8`) o‘zgartirilmadi;
`pro/tiers-premium` (`531ba02`) faqat o‘qildi.

`paid/pro-premium` = `fix/images-apparatus@215d3e8` + `git merge pro/tiers-premium@531ba02` (merge commit, rebase/force
yo‘q). Birlashma 112 faylni o‘zgartirdi (+18 242 / −140): Pro ishining hammasi keldi —
- server: `cloudflare/src/{billing,trial,tiers,progrants,x509}.ts`, migratsiyalar `0014…0018` (faqat fayl, production
  D1 ga qo‘llanmagan), server testlari va fixturalar;
- ilova: `lib/core/entitlements/*`, `lib/core/build_flags.dart` (`LG_PRO_ENABLED`, `LG_FAKE_PURCHASES`),
  `lib/core/backend/pro_grants.dart`, to‘lov oynasi (`/profile/purchase`), “Obuna” ekrani (`/profile/subscription`),
  admin “Pro berish”, `pro_gate.dart` (`requireFeature`/`pushGated`/`labGate`), 20 ta ekranda yopish nuqtalari;
- ARB `pro*` kalitlari (uz/ru — 154, en — 187 yozuv, metama’lumot bilan), Pro testlari va qorovullari, `docs/PRO_*`.

Reliz tarmog‘idagi hamma narsa joyida qoldi: rasmlar, sxemalar va sxema qismlari paneli, “Qanday foydalaniladi?”
videolari ro‘yxati (`assets/howto/`, `HowToVideoService`), ilmiy ko‘rik jadvallari, ARB’dagi ~650 yangi kalit.

## 2. Ziddiyatlar va yechim

| Fayl | Ziddiyat | Yechim |
|---|---|---|
| `lib/l10n/app_{uz,ru,en}.arb` | ikkala tarmoq fayl oxiriga kalit qo‘shgan (matnli) | **kalitlar birlashmasi**: reliz tomoni so‘zma-so‘z, `pro/tiers-premium` dagi bazada yo‘q kalitlar oxiriga qo‘shildi. Ikkala tomonda ham o‘zgargan kalit yo‘q (skript tekshirdi). Reliz olib tashlagan `toifaNoGuaranteeNote`, `toifaPlanDisclaimer` qaytarilmadi. JSON to‘g‘ri, ziddiyat belgisi yo‘q. Natija: uz/ru 3790, en 4242 yozuv |
| `lib/l10n/gen/*` (4 fayl) | generatsiya qilingan | qo‘lda tahrirlanmadi — `flutter gen-l10n` bilan qayta yasaldi (faqat qo‘shilishlar, tarjima qilinmagan xabar yo‘q) |

Avtomatik qo‘shilgan, lekin qo‘lda ko‘rib chiqilgan umumiy fayllar (ikkala tomon xatti-harakati saqlangan):
- `lib/main.dart` `createServices`: `howToVideos` (reliz) **va** `entitlements` (Pro, bayroq o‘chiq — `disabled()`);
  `main()` da `howToVideos.ensureLoaded()` va faqat `if (BuildFlags.proEnabled)` ichida `entitlements.start()`.
- `lib/app/app_scope.dart`: ikkala `required` maydon; `proGrants` faqat bayroq bilan.
- `test/helpers/harness.dart`: reliz — video ro‘yxati yuklanishi; Pro — `proEnabled`/soxta do‘kon override’lari va
  deterministik kunlik seed.
- `lib/app/widgets/lg_page.dart` `buildAllChildren`: bu tuzatish `main` da (`8965d0e`) allaqachon bor; Pro dagi
  `ea5ef8a` — aynan shu yamoq, birlashmada sof farq nol → bitta implementatsiya (ziddiyat yo‘q).
- 15 ta Lab ekrani: reliz `HowToButton`, Pro `pushGated` — ikkalasi ham bor.
- `pubspec.yaml`/`.lock`: `in_app_purchase*` (Pro) + `assets/howto/` (reliz).
- `docs/GUARDS.md`: ikkala bo‘lim; `docs/DECISIONS.md`: Pro varianti (D-71…D-76) + yangi D-77 (oxiriga).
- `site/privacy/index.html`: **reliz versiyasi qoldirildi** — Pro’dagi qo‘lda qo‘shilgan §10a `check_site.py` ni
  buzadi (sayt `docs/store/PRIVACY_POLICY.md` dan yasaladi). §10a — matnlar agenti uchun TODO (5-bo‘lim).

## 3. Yangi siyosat (D-77) va qorovullar

D-77 faqat shu tarmoqda D-58 ni almashtiradi (`main` da D-58 kuchda). Yangi fayl
`test/guards/paid_policy_d77_guard_test.dart`:
- (a) bayroqlar standart holati aniq: `LG_PRO_ENABLED`, `LG_FAKE_PURCHASES`, `LG_PARTNER_ADS`, `LG_ALL_FEATURES_OPEN`
  — `false`, `defaultValue` yo‘q, bool bayroqlar ro‘yxati to‘liq; `ProGatePolicy.gated` bo‘sh; do‘kon kirish taklifi yo‘q;
  server `wrangler.toml` da `LG_BILLING_ENABLED`/`LG_BILLING_SANDBOX`/`TRIAL_PLATFORMS` yo‘q; standart servislar —
  hamma imkoniyat ochiq;
- (b) narx literali yo‘q: `lib/` (faqat `pro_catalog.dart` `ProPricing` dan tashqari), ARB, `cloudflare/src`;
  `ProPricing` = D-76 narxlari; `pro_catalog.dart` va `billing_catalog.dart` da **UNCONFIRMED-until-created-in-store**
  belgisi;
- (c) sinov 7: `ProTrialConfig.serverTrialDays`, `TRIAL_DAYS`, server testi, ARB `proPrivacyTrialNote` (uch tilda);
  eski uzun (SUPERSEDED) sinov matni faqat tarixda — D-70/D-71/D-72 ga va `PRO_PROPOSAL_D72.md`,
  `PRO_READINESS_2026-10-24.md`, `TIERS_AUDIT_2026-10-25.md`, `TIERS_INTEGRATION_PLAN.md` ga SUPERSEDED belgisi
  qo‘shildi (qaror raqamlari o‘zgartirilmadi);
- (d) do‘kon asoslari: tiklash tugmasi to‘lov oynasi va “Obuna” ekranida; widget testi (soxta do‘kon): har mahsulotda
  narx+davr xarid tugmasidan yuqorida, bir kartada; Profil → Obuna → tiklash yetib boriladi; Pro ekranlaridagi URL lar
  faqat Apple/Play/`labguide.nfcstore.uz`; Stripe/PayPal/Payme/Click va h.k. yo‘q.

Boshqa o‘zgarishlar: `BillingLinks.privacyPolicy` GitHub o‘rniga `Contact.privacyPolicyUrl`
(`https://labguide.nfcstore.uz/privacy/`, audit C4); `product_policy_guard_test` va server `guards.test.ts`
nomlari D-77 ga moslandi (mazmuni o‘zgarmadi); `tool/site/check_site.py`: “Pro/obuna/subscription” taqig‘i endi faqat
`privacy/` dan tashqari sahifalarda, hamma sahifada narx literali va 7 dan boshqa sinov muddati taqiqlangan
(self-test kengaytirildi; `test_guards.py` yangilandi). Pro’dagi §10a sahifasi yangi qoidalarda faqat “eskirgan”
xatosini beradi (manbada yo‘q).

## 4. O‘CHIQ (standart) holat

| O‘chirgich | Qiymat |
|---|---|
| `BuildFlags.proEnabled` (`LG_PRO_ENABLED`) | `false` — Pro UI, yo‘llar, do‘kon plagini ishga tushmaydi |
| `ProGatePolicy.gated` | `{}` — hech narsa yopilmaydi (`plannedLabGate` faqat reja) |
| `LG_FAKE_PURCHASES`, `LG_PARTNER_ADS`, `LG_ALL_FEATURES_OPEN` | `false` |
| `ProTrialConfig.storeIntroOffersAllowed` / `freeTrialDays` | `false` / `null` |
| Server `LG_BILLING_ENABLED` | o‘rnatilmagan → `/v1/billing/*`, `/v1/pro/*`, admin grant — 404 |
| Sinov uzunligi | 7 kun (o‘zgartirilmadi) |

## 5. Test natijalari (2026-10-25, shu tarmoqda, haqiqiy ishga tushirish)

Har Flutter ishga tushirish `flock /tmp/flutter_test.lock` ostida, ketma-ket.
- `flutter analyze` — **xato yo‘q**.
- `test/guards/` — **193 test PASS** (shu jumladan yangi `paid_policy_d77_guard_test.dart` — 16 test; buzib ko‘rilganda
  narx va eski sinov matnini haqiqatan ushladi).
- Pro + l10n to‘plami (13 fayl: `entitlements`, `plan_matrix`, `trial_entitlement`, `pro_readiness_d75`,
  `admin_grant_entitlement`, `entitlements_flow`, `lab_gate`, `pro_flag_off`, `subscription_screen`, `admin_pro_grant`,
  `arb_parity`, `no_draft_wording`, `ru_terminology`) — **142 test PASS**.
- To‘liq `flutter test` (202 fayl, guard/unit/widget/integration) — **2364 test PASS, 1 skip** (oldindan bor:
  `test/integration/classroom_local_worker_test.dart` — mahalliy Worker `LG_LOCAL_API` kerak), xato yo‘q.
- `python3 tool/l10n/normalize_uz_apostrophes.py --check` — o‘zgartiriladigan satr 0.
- `python3 tool/site/check_site.py` — 4 sahifa, xato yo‘q; `--self-test` — hammasi o‘tdi; `tool/site` unittest — 7 OK;
  `tool/slides` — 89 OK, `tool/video` — 7 OK, `tool/ai/tests` — 93 OK.
- Server (`cloudflare/`, repo tashqarisidagi nusxada, `node_modules` repoga qo‘shilmadi): `tsc --noEmit` — xato yo‘q;
  `vitest run` — **24 fayl, 332 test PASS**.

## 6. Qolgan ishlar

1. **Matnlar agenti:** `docs/store/PRIVACY_POLICY.md` ga obuna/sinov bo‘limi (Pro’dagi `site/privacy` §10a mazmuni,
   7 kun), so‘ng `python3 tool/site/build_site.py`; Foydalanish shartlari; `docs/store/APP_STORE.md:10`,
   `PLAY_CONSOLE_UPLOAD.md:18` (“to‘lov yo‘q (D-58)”) — IAP ro‘yxati, App Privacy “Purchase History”/“Device ID”,
   Data safety. Yurist: sinov xeshini 24 oy saqlash.
2. **Yoqish (rahbar, keyingi bosqich):** `gated` ro‘yxati va grandfathering, `LG_PRO_ENABLED` build, server
   secretlari va `LG_BILLING_ENABLED`, migratsiyalar 0014–0018 (avval test D1).
3. **Do‘konlar (egasi):** 8 App Store mahsuloti / 4 Play obuna × 2 base plan — id’lar va narxlar
   UNCONFIRMED-until-created-in-store; Play’da free-trial offer YARATILMAYDI; Paid Applications Agreement, soliq, bank.
4. Sinov ishlashi uchun qurilma attestatsiyasi (Play Integrity / App Attest) yozilmagan → server 503, tugma yo‘q.
5. Talaba rejasi sotuvda ko‘rinmaydi (talaba tasdig‘i yo‘q); `assignments` ga `requireFeature` ulanmagan; ustoz reja
   nomi “Ustoz” / “Ustoz Pro” bir xil emas; mehmon xarid qila olmaydi (Apple 5.1.1 xavfi).
6. `in_app_purchase` bog‘liqligi bayroq o‘chiq bo‘lsa ham Android manifestga `BILLING` ruxsatini qo‘shadi — Pro’siz
   build shu tarmoqdan yig‘ilmasin (bepul build — `main`/`fix/images-apparatus` dan).
7. HowTo videolari va sxema paneli Lab sahifalari ichida: `gated` to‘ldirilsa, ular ham yopiq sahifa ichida qoladi —
   bepul qolishi kerakmi, qaror va `lab_gate_test` holati kerak.
8. Haqiqiy do‘kon sandbox matritsasi (xarid, tiklash, bekor, grace, refund, boshqa hisob, oflayn) — QILINMAGAN.

## 7. Matnlar va huquqiy (`paid/txt`, 2026-10-25) — matnlar agenti

Mahalliy tarmoq `paid/txt` (`paid/pro-premium@21b5a24` dan). Push/PR/build/deploy/do‘kon API — QILINMAGAN.
- **ARB `pro*`** (uz/ru/en): reja nomlari yakuniy — uz Talaba Pro / Ustoz Pro / Mutaxassis Pro / Premium; ru Студент Pro /
  Преподаватель Pro / Специалист Pro / Premium; en Student Pro / Teacher Pro / Specialist Pro / Premium (“Ustoz” ↔ “Ustoz Pro”
  nomuvofiqligi tuzatildi). To‘lov oynasi, “Obuna” ekrani, sinov (7 kun, bir marta, kartasiz; do‘kon taklifi ko‘rsatilsa narx va
  yangilanish shartlari do‘kon oynasidagidek), muddat tugash (“faqat pullik imkoniyatlar yopiladi; bepul va ma’lumot qoladi”),
  bekor qilish/qaytarish/oflayn/mehmon/xato matnlari. 20 yangi kalit (`proPayCancelPath*`, `proPayStoreTrialNote`,
  `proPayRefund*`, `proPayCancelledUntil`, `proPayGraceNote`, `proPayOffline*`, `proPayAgreeNote`, `proPayFeat*` yangilari,
  `proTermsBody`, `proPrivacyBody`, `proAccountDeleteBody`) — ularning bir qismi Dart’ga ULANMAGAN (quyida).
- **Huquqiy:** `PRIVACY_POLICY.md` ga 16-bo‘lim (obuna, sinov, to‘lov; 17-bo‘lim — o‘zgarishlar), `TERMS_OF_USE.md` (yangi,
  uz/ru/en) → `site/terms/` (generatsiya). `Contact.termsOfUseUrl`; `BillingLinks.termsOfUse` endi Apple standart EULA emas,
  shu manzil. Sayt qoidalari: obuna so‘zlari `privacy/` va `terms/` da.
- **Do‘kon hujjatlari:** `APP_STORE.md` 16-bo‘lim, `PLAY_CONSOLE_UPLOAD.md` 7-bo‘lim (obuna nomlari/tavsiflari narxsiz,
  review izohi, sandbox qadamlari placeholder, App Privacy / Data safety — NEEDS_OWNER_CHECK).
- **Izchillik testi:** `test/unit/paid_texts_consistency_test.dart`.
- **Ochiq (egasi/yurist):** `PRIVACY_OPEN_QUESTIONS.md` E-bo‘lim (24 oy — NEEDS_LAWYER_REVIEW; shartlar tomoni va Apple
  “custom EULA” bandlari; qurilma tekshiruvi; kuchga kirish sanasi; ilova ichidagi `termsBody/privacyBody/accountDeleteBody`
  hali “bepul ilova” deydi — `pro*` almashtiruvchilari tayyor, Dart’da kalitni almashtirish kerak).

