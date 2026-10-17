# LabGuide server — Cloudflare Workers + D1

Egasi qarori (2026-10-10): server **Cloudflare Workers + D1** bepul tarifida,
email kodlari **Resend** orqali (`alideveloper.uz` domeni; zaxira — Brevo, `EMAIL_PROVIDER=brevo`).
Supabase kodi (`supabase/`) xavfsizlik qoidalari manbai sifatida qoladi.

> Holat: kod, testlar va CI tayyor. **Deploy qilinmagan** — buning uchun
> quyidagi “Egasi uchun qadamlar” kerak.

## Arxitektura

```
Flutter ilova ──HTTPS/JSON──▶ Worker `labguide-api` (cloudflare/src) ──▶ D1 `labguide-db`
   (CloudflareLabBackend)          │                                     (SQLite, EEUR)
                                   ├──▶ Resend API (faqat kirish kodi xati; ixtiyoriy Brevo)
                                   └──▶ Workers AI (binding `AI`: hujjat tekshiruvi, tarjima)
```

| Joy | Nima |
|---|---|
| `cloudflare/src/app.ts` | marshrutlar, umumiy xato ishlovi (ichki tafsilot chiqmaydi), CORS, kunlik tozalash (cron) |
| `cloudflare/src/auth.ts` | email OTP, sessiyalar, profil, admin TOTP, super admin tekshiruvi, hisobni o‘chirish |
| `cloudflare/src/admins.ts` | adminlar boshqaruvi (D-44): super admin email bo‘yicha admin qo‘shadi/olib tashlaydi |
| `cloudflare/src/community.ts` | hamjamiyat (D-43): mutaxassisni AI bilan tasdiqlash, savol-javob, ovoz, shikoyat, tarjima keshi, admin moderatsiyasi, egasi tasdig‘i va seed |
| `cloudflare/src/groups.ts` | guruhlar, a’zolik, mavzular, savol-javob belgilari, test sessiyalari, natijalar |
| `cloudflare/src/crypto.ts` | HMAC, SHA-256, AES-GCM, TOTP (faqat WebCrypto) |
| `cloudflare/src/email.ts` | email yuboruvchi: Resend (standart) / Brevo, uz/ru/en matn |
| `cloudflare/migrations/` | D1 sxemasi: `0001_auth`, `0002_classroom`, `0003_planned_ports` (faqat sxema), `0004_teacher_topics` (ustoz ro‘yxati, mavzu bosqichlari va testi), `0005_community` (hamjamiyat), `0006_admin_grants` (qo‘shilgan adminlar, D-44) |
| `cloudflare/seed/` | `community_seed.json` (egasi tasdiqlagan 2 ta savol-javob), `community_seed.example.json` (sxema) |
| `cloudflare/test/` | vitest + `@cloudflare/vitest-pool-workers` (haqiqiy workerd va lokal D1) |
| `lib/core/backend/cloudflare_backend.dart` | ilova adapteri `CloudflareLabBackend` |
| `test/unit/cloudflare_backend_test.dart` | adapter testlari (soxta HTTP), shu jumladan kontrakt xatolari xaritasi |

Ilova qaysi serverni ishlatishini build vaqtida biladi (`lib/main.dart`):
`--dart-define=LG_API_URL=https://…` berilsa — Cloudflare; aks holda
`LG_SUPABASE_URL/KEY` bo‘lsa — Supabase; ikkalasi ham bo‘sh — “server hali
ulanmagan” (mehmon rejimi va oflayn kontent o‘zgarmaydi).

Bepul tarif hisobdagi **barcha** Workerlar uchun umumiy (kuniga 100 000
so‘rov). Shuning uchun: ilova ochilganda sessiya tarmoqsiz tiklanadi (token
birinchi so‘rovda tekshiriladi), har endpoint bitta-ikkita D1 so‘rovi yoki
`batch`, tozalash kuniga bir marta (cron). Deploy faqat `labguide-api` nomiga
— hisobdagi boshqa Workerlarga tegilmaydi.

## Endpointlar (`/v1`)

Javoblar JSON. Xato: `{"error": "<kod>", ...}`; HTTP holati: 400 noto‘g‘ri
ma’lumot, 401 sessiya yo‘q, 403 ruxsat yo‘q, 404 topilmadi (yoki begona guruh —
borligi ham bildirilmaydi), 409 holatga zid (masalan, ikkinchi topshirish),
413/415 tana, 429 limit (`retry_after` soniya), 501 hali ko‘chirilmagan,
503 server sozlanmagan, 500 `internal` (tafsilotsiz).

### Auth va hisob

| Metod va yo‘l | Kim | Nima |
|---|---|---|
| `GET /v1/health` | hamma | `{ok:true}` |
| `POST /v1/auth/otp/request` `{email, language?}` | hamma | 6 raqamli kod email orqali (til `language`, standart uz); `{retry_after:60, valid_for:600}` |
| `POST /v1/auth/otp/verify` `{email, code}` | hamma | `{token, user_id, expires_at}` (sessiya 60 kun) |
| `GET /v1/auth/providers` | hamma | `{google, apple, apple_web}` — qaysi kirish usullari sozlangan (ilova tugmani shunga qarab ko‘rsatadi; D-56) |
| `POST /v1/auth/google` `{id_token, nonce}` | hamma | Google ID token serverda tekshiriladi; `{token, user_id, expires_at, new_user, linked, provider, email, email_masked}`. Sozlama yo‘q — `503 not_configured` |
| `POST /v1/auth/apple` `{id_token, nonce}` | hamma | xuddi shunday, Apple uchun |
| `POST /v1/auth/apple/callback` | Apple (form POST) | faqat Android veb-oqimi (`APPLE_SIGNIN_SERVICE_ID` bo‘lsa): natijani ilovaga `intent://` bilan qaytaradi |
| `POST /v1/auth/logout` | sessiya | joriy tokenni bekor qiladi |
| `POST /v1/auth/logout-all` | sessiya | hamma qurilmalardan chiqish |
| `GET /v1/me` | sessiya | `{user_id, role, language, admin_account, aal, admin, super_admin, reviewer, teacher, identities}` (`super_admin` — email `LG_ADMIN_EMAILS` da; `identities` — bog‘langan `google`/`apple`) |
| `POST /v1/me/teacher` | sessiya | ustoz sifatida ro‘yxat (`registerTeacher`) |
| `PUT /v1/me/profile` `{role?, language?}` | sessiya | rol: `doctor/lab/student/teacher` (boshqasi — 400) |
| `DELETE /v1/me` `{apple_authorization_code?}` | sessiya | hisob va unga bog‘liq hamma narsa o‘chadi. Apple bilan bog‘langan va `APPLE_SIGNIN_*` sozlangan bo‘lsa — kod almashtirilib Apple tokeni bekor qilinadi (saqlanmaydi); kod/sozlama yo‘q bo‘lsa ham hisob o‘chadi, natija `audit_log` da |
| `GET /v1/auth/mfa` | admin hisobi | TOTP holati |
| `POST /v1/auth/mfa/enroll` | admin hisobi, faktor hali yo‘q | TOTP kalit va `otpauth://` URI |
| `POST /v1/auth/mfa/verify` `{code}` | admin hisobi | sessiya `aal2` bo‘ladi |

### Google / Apple bilan kirish (D-56) — `cloudflare/src/social.ts`

Email-kod kirishi yoniga ikkinchi usul; mehmon rejimi o‘zgarmaydi. Batafsil egasi
qadamlari: `docs/AUTH_SOCIAL_LOGIN.md`.

- **Token tekshiruvi serverda:** imzo (provayder JWKS: Google `…/oauth2/v3/certs`,
  Apple `…/auth/keys`; faqat RS256, `kid` bo‘yicha; `cache-control` muddatiga
  keshlanadi, noma‘lum `kid` bo‘lsa 5 daqiqada ko‘pi bilan bir marta qayta
  yuklanadi — kalit almashtirishni qo‘llaydi; yuklab bo‘lmasa eski kesh), `iss`,
  `aud` (Google: `GOOGLE_CLIENT_IDS` ro‘yxati; Apple: `uz.labguide.app`
  (+ ixtiyoriy Services ID)), `exp`/`iat`/`nbf` (±60 s), `email_verified`,
  **nonce** (ilova provayderga `sha256(xom nonce)` beradi, serverga xomini
  yuboradi; token `nonce` i shunga teng bo‘lishi shart).
- **Takroriy ishlatishga qarshi:** `auth_replay` jadvali — `sha256(provider|sub|iat|exp|nonce)`
  token muddatigacha (kunlik cron tozalaydi). Token yoki nonce saqlanmaydi.
- **Bitta email = bitta hisob:** birinchi kirishda tasdiqlangan email mavjud
  hisob emailiga (HMAC) teng bo‘lsa — o‘sha hisobga bog‘lanadi (`linked:true`),
  dublikat yaratilmaydi; aks holda yangi hisob. Keyingi kirishlar provayder `sub`
  i bo‘yicha (`auth_identities`) — Apple private relay emaili yoki email o‘zgarsa
  ham hisob o‘sha. Tasdiqlanmagan email — `403 email_not_verified`, email yo‘q
  (birinchi kirishda) — `400 email_required`.
- **Admin:** bu yo‘l bilan admin vakolati BERILMAYDI (faqat email kodi); ro‘yxatdan
  chiqqan adminning vakolati esa olinadi. Sessiya `aal1`.
- **Limit:** IP bo‘yicha 10 daqiqada 60 urinish (`social-ip`).
- **Xatolar (401 `invalid_token`):** `token_expired`, `nonce_mismatch`,
  `replayed_token`; JWKS yetib bo‘lmasa `502 provider_unavailable`.
- **Apple revoke:** hisob o‘chirilganda ilova Apple’dan yangi `authorizationCode`
  oladi → server uni `/auth/token` da almashtiradi (`client_secret` — ES256 JWT,
  `.p8` kalit bilan) → olingan refresh token darhol `/auth/revoke` ga beriladi.
  `sub` mos kelmasa bekor qilinmaydi. Hech narsa saqlanmaydi.

Secretlar (hammasi ixtiyoriy; yo‘q bo‘lsa shu usul `503 not_configured`):
`GOOGLE_CLIENT_IDS`; `APPLE_SIGNIN_TEAM_ID` + `APPLE_SIGNIN_KEY_ID` +
`APPLE_SIGNIN_PRIVATE_KEY` (uchalasi birga — Apple yoqiladi);
`APPLE_SIGNIN_CLIENT_ID` (standart `APPLE_BUNDLE_ID`/`uz.labguide.app`),
`APPLE_SIGNIN_SERVICE_ID` (Android uchun).

### Ustoz–talaba (endpoint ↔ `LabBackend` metodi)

Kontrakt — `lib/core/backend/lab_backend.dart`; uning bajariladigan ta’rifi
`test/helpers/fake_backend.dart` + `test/unit/classroom_rules_test.dart`
(va `supabase/tests/30_teacher_topics.sql`). Worker testlari:
`cloudflare/test/contract.test.ts` (har qoida uchun alohida tekshiruv).

| `LabBackend` metodi | Metod va yo‘l | Kim | Nima / xato → `BackendFailure` |
|---|---|---|---|
| `registerTeacher()` | `POST /v1/me/teacher` | sessiya (= email kodi tasdiqlangan hisob) | ustoz sifatida ro‘yxat; qayta chaqirish xato emas; admin bermaydi. Sessiyasiz — `unauthorized` |
| `myAccess()` | `GET /v1/me` | sessiya | `teacher` maydoni qo‘shildi |
| `myGroups()` | `GET /v1/groups` | sessiya | mening guruhlarim; kod faqat ustozga |
| `createGroup(name, displayName:)` | `POST /v1/groups` `{name, display_name?}` | ro‘yxatdan o‘tgan ustoz | nom 3–80; ≤ 10 guruh (`429 limit_groups` → `rateLimited`); ustoz emas — `403` → `forbidden` (profil roli `teacher` yetmaydi) |
| `joinGroup(code, displayName:)` | `POST /v1/groups/join` `{code, display_name?}` | sessiya | qayta qo‘shilish hech narsani o‘zgartirmaydi (taxallus ham); noto‘g‘ri kod — `notFound`; ≤ 200 a’zo (`429 group_full` → `rateLimited`); kod taxmini limiti → `rateLimited` |
| `setMyAlias(g, alias)` | `PUT /v1/groups/:g/alias` `{alias}` | a’zo | taxallus 2–24 (bo‘sh/null — tartib raqami); begona guruh `404` → `forbidden` |
| `leaveGroup(g)` | `POST /v1/groups/:g/leave` | talaba | a’zo emas (`404`) — xato emas; ustoz — `400` → `invalid` |
| `groupMembers(g)` | `GET /v1/groups/:g/members` | a’zo | `{user_id, member_role, display_name (faqat taxallus yoki null), seat_no (talaba raqami, ustozda null), label, joined_at}`; talaba — o‘zi va ustoz; begona — `404` → `[]` |
| `removeMember(g, u)` | `DELETE /v1/groups/:g/members/:u` | ustoz | ustozni emas; `404 member_not_found` — xato emas; begona — `forbidden` |
| `groupTopics(g)` | `GET /v1/groups/:g/topics` | a’zo | `{group_id, topic_id, opened_at, lecture_done_at, oral_done_at, test_assignment_id, open, closed_at}`; yopilgani ilovada ko‘rinmaydi; begona — `[]` |
| `openTopic(g, t)` | `PUT /v1/groups/:g/topics/:t` | guruh egasi-ustoz | qayta — o‘zgarmaydi; id `^[A-Za-z0-9][A-Za-z0-9_.:-]{0,79}$` (aks holda `invalid`); ≤ 300 mavzu (`429 limit_topics`); talaba `403`, begona `404` → `forbidden` |
| `markTopicStage(g, t, stage)` | `POST /v1/groups/:g/topics/:t/stage` `{stage: lecture\|oral}` | ustoz | mavzu ochiladi; vaqt bir marta yoziladi; boshqa stage — `invalid` |
| `startTopicTest(...)` | `POST /v1/groups/:g/topics/:t/test` `{title, question_ids, correct_indexes, time_limit_minutes?}` | ustoz | topshiriq yaratiladi va ochiladi (`topic_id`); mavzuga **bitta** test — ikkinchisi `409 test_exists` → `invalid` (tekshiruv va yozuv bitta tranzaksiyada) |
| `finishTopicTest(g, t)` | `POST /v1/groups/:g/topics/:t/finish` | ustoz | `status=closed`, `due_at=hozir`; yangi urinish yo‘q; testi yo‘q — `404 no_test` → `notFound`; begona — `forbidden` |
| `assignments(g)` | `GET /v1/groups/:g/assignments` | a’zo | `topic_id` bilan; kalit yo‘q; qoralamani faqat ustoz ko‘radi; begona — `[]` |
| `createAssignment(...)` | `POST /v1/groups/:g/assignments` `{title, question_ids, correct_indexes, day_id?, due_at?, time_limit_minutes?, start?}` | ustoz | sarlavha 3–120, savollar 1–50, vaqt 1–180; `start:false` — qoralama |
| `startAssignment(a)` | `POST /v1/assignments/:a/start` | talaba | boshlanish vaqti (bir marta) + `server_now`; yakunlangan/muddati o‘tgan — `409` → `invalid`; talaba emas — `forbidden` |
| `submitAssignment(a, answers)` | `POST /v1/assignments/:a/submit` `{answers}` | talaba | ball serverda; bir marta; **boshlangandan limit + 2 daqiqa**; yakunlangan test — yakunlanishdan oldin boshlaganlarga + 2 daqiqa; kech/takror — `409` → `invalid` |
| `submissions(a)` | `GET /v1/assignments/:a/submissions` | a’zo | ustoz — hamma (har savol `correct`); talaba — faqat o‘zi; begona ustoz va **admin** — `[]` |
| `groupSubmissions(g)` | `GET /v1/groups/:g/submissions` | a’zo | xuddi shunday, guruh bo‘yicha |
| `assignmentKey(a)` | `GET /v1/assignments/:a/key` | ustoz | to‘g‘ri javoblar; boshqalar — `forbidden` |

Worker’da qo‘shimcha (ilova hozircha chaqirmaydi; `CloudflareLabBackend`
ning interfeysdan tashqari metodlari sifatida saqlangan, vakolati o‘sha —
faqat guruh egasi-ustoz):

| Metod va yo‘l | Adapter metodi | Nima |
|---|---|---|
| `DELETE /v1/groups/:g` | `deleteGroup` | guruhni butunlay o‘chirish |
| `POST /v1/groups/:g/code` | `rotateJoinCode` | yangi kod (eski QR ishlamaydi) |
| `DELETE /v1/groups/:g/topics/:t` | `closeTopic` | mavzuni talabalardan yashirish (`PUT` qayta ochadi) |
| `GET/PUT /v1/groups/:g/marks`, `DELETE …/marks/:id` | `marks/putMark/deleteMark` | savol-javob belgilari (`correct/partial/incorrect/skipped`, baho 1–5); talaba faqat o‘ziniki |
| `POST /v1/assignments/:a/open` · `/close` | `openAssignment/closeAssignment` | qoralama sessiyani boshlash / yakunlash |

**Xatolar xaritasi** (`CloudflareLabBackend._call`): 400/409/413/415 →
`invalid`, 401 → `unauthorized` (sessiya o‘chadi, `sessionLost`), 403 →
`forbidden`, 404 → `notFound`, 429 → `rateLimited`, 501/503 → `unavailable`,
502/504 va tarmoq/timeout → `network`, boshqasi → `unknown`. Worker a’zo
bo‘lmaganga guruh borligini bildirmaydi (`404`); kontraktda esa (Supabase RLS
kabi) ro‘yxat o‘qish — bo‘sh ro‘yxat, ustoz/talaba amali — `forbidden`.
Shuning uchun adapter shu metodlarda `404` ni `[]` yoki `forbidden` ga
aylantiradi, aniq kodlar (`no_test`, `member_not_found`) alohida.

### Hamjamiyat (D-43) — `cloudflare/src/community.ts`

Ilova: `CommunityBackend` (`lib/core/backend/community_backend.dart`),
`CloudflareLabBackend` amalga oshiradi; testlarda `FakeCommunityBackend`.
Hamjamiyat jadvallarida foydalanuvchi `user_hash = HMAC(server kaliti, user_id)`
bilan saqlanadi. Ommaviy javoblarda hash/email yo‘q — muallif `{kind:
owner|specialist|member, name (faqat egasi), verified, method, role, country, is_me}`.

| Metod va yo‘l | Kim | Nima |
|---|---|---|
| `GET /v1/community/me` | sessiya | `{status: none\|verified\|rejected\|suspended, method: ai_auto\|manual_document_review, role, country, reason, verified_at, institution, specialty_code, credential, year, is_owner, can_ask, can_answer, admin}` |
| `POST /v1/community/verify?role=&country=` (tana — rasm, `image/jpeg\|png`) | sessiya | ≤ 5 MB, sehrli baytlar tekshiriladi, PDF — `415 pdf_not_supported`; **kuniga 3 urinish** (+ IP 20); Workers AI (`LG_VERIFY_MODEL`) qat’iy JSON → `verified` faqat hujjat + lab/tibbiy soha + muassasa ko‘rinadi + ishonch ≥ 0,7. **Rasm saqlanmaydi**; sabab — faqat kodlar (`doc=diploma;field=ok;…`). Tasdiqlangan — `409`; to‘xtatilgan — `403 suspended`; AI yo‘q/xato — `503 ai_unavailable` |
| `GET /v1/community/questions?topic=&mine=1&limit=&offset=` | hamma (mehmon ham; `mine` — sessiya) | `{items, total, next_offset}`; qadalganlar birinchi; to‘xtatilgan muallif postlari ko‘rinmaydi |
| `POST /v1/community/questions` `{title, body, topic?, lang?}` | sessiya (to‘xtatilmagan) | sarlavha 10–200, matn 10–4000; email/telefon — `400 contact_data`; mavzu `analyte:<id>`/`condition:<id>`; til matndan aniqlanadi (kirill → ru; o‘zbekcha belgilar → uz; aks holda `lang`/en); **kuniga 5** |
| `GET /v1/community/questions/:q` | hamma | savol + javoblar (eng yaxshi, so‘ng ovoz, so‘ng vaqt) + `viewer {can_answer, can_vote, is_author, admin}` |
| `POST /v1/community/questions/:q/answers` `{body, lang?}` | **tasdiqlangan mutaxassis** | aks holda `403 not_verified`; kuniga 20 |
| `POST/DELETE /v1/community/answers/:a/vote` | tasdiqlangan mutaxassis | o‘z javobiga emas (`own_answer`); takror sanalmaydi |
| `POST /v1/community/questions/:q/best` `{answer_id\|null}` | savol muallifi | boshqalar — `403 not_author` |
| `POST /v1/community/reports` `{kind: question\|answer, id, reason}` | sessiya | o‘z postiga emas; bitta odam bitta postga bir marta; kuniga 20; muallifga **3 ta turli sanaladigan shikoyatchi** (tiklashdan keyingilar; sanaladi — tasdiqlangan mutaxassis, admin yoki hisobi ≥ 3 kun; qolganlari faqat admin panelida) → `suspended` (egasi bundan mustasno); javob `202` (son oshkor qilinmaydi) |
| `POST /v1/community/translate` `{kind, id, lang}` | hamma | `LG_TRANSLATE_MODEL` (m2m100), qator-baqator; `(post, til)` bo‘yicha D1 keshi — qayta so‘rovda AI chaqirilmaydi; yangi tarjima soatiga 60 (foydalanuvchi) / 30 (IP); bir xil til — `400 same_language` |
| `POST /v1/community/questions/:q/pin` `{pinned}`, `DELETE /v1/community/questions/:q`, `DELETE /v1/community/answers/:a` | admin (aal2) | qadash / o‘chirish (audit) |
| `GET /v1/admin/community/members?status=suspended\|verified\|rejected` | admin | holat, kasb, mamlakat, shikoyatchilar soni, oxirgi 10 shikoyat (sabab + parcha) |
| `POST /v1/admin/community/members/:h/restore` · `/revoke` · `/suspend` | admin | tiklash (oldingi holat), tasdiqni bekor qilish (egasidan tashqari; to‘xtatilgan bo‘lsa to‘xtatish saqlanadi; bekor qilingan a’zo AI orqali qayta tasdiqlanmaydi — `403 revoked`), qo‘lda to‘xtatish |
| `POST /v1/admin/seed-owner-verification` `{email}` | admin, email **`LG_ADMIN_EMAILS`** da | email serverda HMAC qilinadi; hisob topilmasa `404 user_not_found` (avval ilovaga kiring). Metadata kodda qat’iy (`OWNER_VERIFICATION`): `clinical_lab_diagnostics`, Andijon davlat tibbiyot instituti, 3.03.01 Klinik laborator diagnostika, birlamchi ixtisoslik kursi, 2026, `manual_document_review`; `is_owner=1` — postlari `LG_OWNER_DISPLAY_NAME` nomi bilan |
| `POST /v1/admin/community/seed` (tana ixtiyoriy; bo‘sh tana — serverga biriktirilgan `cloudflare/seed/community_seed.json`) | admin; egasi tasdiqlangan bo‘lishi shart (`409 owner_not_verified`) | savol va javoblar egasi hisobidan; `seed_id` bo‘yicha **idempotent** (`{created, skipped}`) |
| `POST /v1/admin/community/launch` (tana yo‘q) | admin (aal2); chaqiruvchining O‘Z emaili `LG_ADMIN_EMAILS` da | 1) egasi tasdig‘i (chaqiruvchi uchun), 2) biriktirilgan seed. Idempotent: `{owner_verified, questions_added, answers_added}`. Ilovada: Profil → Admin panel → “Hamjamiyatni ishga tushirish” |

Hisob o‘chirilganda hamjamiyatdagi hamma narsa (savollar va ularga javoblar,
javoblar, ovozlar, shikoyatlar, tarjimalar, holat) o‘chadi.

**Egasi uchun (deploydan keyin, faqat supervisor/egasi):** eng oson yo‘l — ilovadagi bir tugma, `docs/OWNER_COMMUNITY_LAUNCH.md`. Qo‘lda variant:
1. Ilovaga egasi emaili bilan kiring → Admin → TOTP (aal2).
2. `POST /v1/admin/seed-owner-verification` `{"email":"<LG_ADMIN_EMAILS dagi email>"}`.
3. `POST /v1/admin/community/seed` — tana `cloudflare/seed/community_seed.json`.
   (Bearer — ilovadagi aal2 sessiya tokeni; masalan curl bilan.)

### Adminlar boshqaruvi (D-44) — `cloudflare/src/admins.ts`

**Super admin** — maxfiy `LG_ADMIN_EMAILS` dagi email(lar) (egasi). Faqat u
boshqa emailni admin qiladi va olib tashlaydi; super admin API orqali olib
tashlanmaydi (id si yo‘q). Qo‘shilgan admin boshqa barcha admin yo‘llariga
(moderatsiya, hamjamiyat, murojaatlar, tekshiruv…) super admin bilan teng kiradi,
faqat adminlarni boshqarish va “Hamjamiyatni ishga tushirish” (egasi tasdig‘i)
bundan mustasno. Har admin amali — **TOTP (aal2)**.

| Endpoint | Kim | Natija |
|---|---|---|
| `GET /v1/admin/admins` | har admin (aal2); 10 daqiqada 60 | `{can_manage, max_granted, admins: [{id\|null, email_masked, kind: super\|granted, active, you, created_at}]}` — email faqat niqoblangan |
| `POST /v1/admin/admins` `{email}` | faqat super admin (aal2); soatiga 10 (noto‘g‘ri so‘rov ham sanaladi) | `201` yozuv; `400 invalid_email`, `409 already_admin` / `already_super_admin` / `too_many_admins` (faol ≤ 20), `403 not_super_admin` |
| `DELETE /v1/admin/admins/:id` | faqat super admin (aal2); soatiga 20 | `204`; `404` (yo‘q, allaqachon olingan yoki super admin) |

Qoidalar:
- `admin_grants`: `email_hmac` (= `users.email_hash` bilan bir xil HMAC), `email_masked`,
  `granted_by_hash` / `revoked_by_hash` (HMAC(user_id)), `created_at`, `revoked_at`.
  Ochiq email hech qayerda yo‘q (vitest tekshiradi).
- Kuchga kirish: hisob bor bo‘lsa — darhol `admins` ga `granted_reason='admin_grant'`;
  bo‘lmasa — o‘sha email kod bilan tasdiqlanganda (`syncAdmin`). Baribir aal2 kerak.
- Olib tashlash: grant `revoked_at`, `admins` dan (faqat `admin_grant`) o‘chadi va
  o‘sha hisob sessiyalari `aal1` ga tushadi — mavjud sessiyalar darhol vakolatsiz
  (har so‘rov `admins` ni o‘qiydi). `manual` va super admin tegilmaydi.
- Audit: `admin_grant_added`, `admin_grant_removed`, `admin_granted`/`admin_revoked`
  (faqat grant id / user id, email yo‘q).
- Hisob o‘chirilsa `admins` yozuvi o‘chadi, grant (email bo‘yicha) qoladi — qayta
  ro‘yxatdan o‘tsa yana admin; kerak bo‘lmasa egasi ilovada olib tashlaydi.
- Testlar: `cloudflare/test/admins.test.ts` (oddiy admin qo‘sha olmaydi, o‘zini
  admin qila olmaydi, aal1 rad, olib tashlangan admin darhol vakolatsiz, validatsiya,
  limitlar, ochiq email saqlanmaydi).

### Reja: hali ko‘chirilmagan (501)

Bular uchun D1 jadvallari (`0003_planned_ports.sql`) bor, lekin endpointlar
**yo‘q** — server `501 not_implemented`, ilova adapteri
`BackendFailure.unavailable` (“ulanmagan”) qaytaradi; hech biri ishlayotgandek
ko‘rsatilmaydi. Hamkorlar ro‘yxati bo‘sh (reklama joylari chiqmaydi).

| Bo‘lim | Yo‘l | Qolgan ish (manba: `supabase/migrations`) |
|---|---|---|
| Taklif va yordam | `/v1/support/*` | murojaat/xabar CRUD, o‘qilgan belgisi; skrinshot uchun yopiq R2 bucket (PNG/JPEG ≤ 5 MB, kuniga 10) |
| Admin panel | `/v1/admin/*` (hozir ham admin+aal2 tekshiriladi) | statistika (faqat ro‘yxatdan o‘tganlar — mehmonlar serverga tushmaydi), foydalanuvchilar (`email_masked`), reviewer berish, audit o‘qish |
| Kontent tekshiruvi | `/v1/reviews` | `content_reviews` |
| Hamkorlar | `/v1/partners*` | feed, arizalar, kunlik umumiy hisoblagich, logo (R2) |

**To‘lov — bu versiyada yo‘q** (D-58): `/v1/billing/*` endpointlari olib tashlandi
(to‘liq ish `pro-later` branchida). Serverda faqat ko‘rinmas `users.plan`/`pro_until`
ustunlari (`migrations/0010_user_plan.sql`) — hech bir endpoint ularni bermaydi.

Eslatma: to‘liq emailni “ochish” (`adminRevealEmail`) bu serverda **bo‘lmaydi**
— email saqlanmaydi.

## Xavfsizlik

- **Email minimal:** bazada faqat `HMAC-SHA256(email)` (kalit — Worker
  secreti) va niqoblangan `da***@gmail.com`. Ochiq email faqat kod yuborish
  paytida xotirada bo‘ladi. Sessiya ichida email qurilmada saqlanadi.
- **OTP:** 6 raqam (`crypto.getRandomValues`, bir tekis), faqat HMAC holida,
  10 daqiqa, bitta kodga 5 urinish (atomar hisob), bir martalik. Limitlar:
  qayta yuborish 60 s; email bo‘yicha soatiga 5 kod va 15 tekshiruv; IP bo‘yicha
  soatiga 60 so‘rov va 10 daqiqada 100 tekshiruv (sinf bitta NAT ortida
  bo‘lishi mumkin). IP saqlanmaydi — limit kalitida faqat HMAC.
- **Sessiya:** 32 baytli tasodifiy opaque token; D1 da faqat SHA-256; 60 kun;
  chiqish/hamma qurilmadan chiqish; muddati o‘tgani cron bilan o‘chadi.
- **Rollar:** profil roli (`student` standart, `teacher` …) faqat ko‘rinish
  uchun. Guruh ochish huquqi — `POST /v1/me/teacher` bilan ro‘yxatdan o‘tgan
  ustoz hisobi (`teacher_accounts`; hisob faqat email kodi tasdiqlangach
  yaratiladi). Ustoz huquqi faqat o‘zi yaratgan guruhlarda; ustoz admin emas. **Admin** — hech bir API bermaydi: faqat maxfiy
  `LG_ADMIN_EMAILS` dagi email kod bilan tasdiqlanganda (ro‘yxatdan chiqsa —
  keyingi kirishda olinadi), super admin ilovada qo‘shgan email (D-44,
  `admin_grants`; olib tashlansa — darhol) yoki egasi qo‘lda (`granted_reason='manual'`).
  Admin yo‘llari qo‘shimcha **TOTP (aal2)** talab qiladi; tasdiqlangan faktor
  bor bo‘lsa yangisini qo‘shib bo‘lmaydi; kodni qayta ishlatish rad etiladi.
  Muhim amallar `audit_log` ga (faqat qo‘shiladi).
- **Ustoz–talaba:** a’zo bo‘lmaganga guruh borligi bildirilmaydi (404);
  talaba boshqa talabaning javobi, belgisi va a’zolar ro‘yxatini ko‘rmaydi;
  kalit faqat ustozga; ball serverda; admin ham guruh mavzusi/natijasini
  ko‘rmaydi. Taxallus — 2–24 belgi, harf/raqam, `@` va havola emas; bo‘lmasa
  tartib raqami (“Talaba NN”, qayta ishlatilmaydi). Guruh kodi taxminiga qarshi: foydalanuvchiga
  15 daqiqada 10, IP ga soatiga 100 urinish.
- **SQL:** faqat parametrli (`?1`) so‘rovlar; test SQL shablonlarida
  tashqi qiymat interpolatsiyasi yo‘qligini ham tekshiradi.
- **CORS:** standart holatda umuman yo‘q (mobil ilovaga kerak emas);
  `LG_ALLOWED_ORIGINS` faqat web build uchun.
- **Xatolar:** `500 {"error":"internal"}` — SQL/stack chiqmaydi; logda faqat
  xato turi (email, kod, kalit logga yozilmaydi). `cache-control: no-store`,
  `nosniff`, tana ≤ 32 KB, faqat `application/json`.
- **Fayllar:** R2 hali ulanmagan — fayl qabul qilinmaydi (yopiq bucket
  rejada).
- **AI:** server hech qanday avtomatik javob yubormaydi.

Testlar (`cd cloudflare && npm test`): 74 ta — avvalgi 52 ta (boshqa ustoz
guruhi, talaba ↔ talaba, o‘zini admin qilish, TOTP, SQL injection, CORS, xato
tafsiloti, limitlar, maxfiylik) va `contract.test.ts` dagi 22 ta ilova
kontrakti testi (ustoz ro‘yxati, taxallus/raqam, mavzu bosqichlari, mavzuga
bitta test — parallel so‘rov bilan ham, yakunlash, vaqt qoidasi limit + 2
daqiqa, begona ustoz/talaba/admin, barcha uzunlik va son cheklovlari).

## Lokal ishlash

```bash
cd cloudflare
npm ci
npm test              # workerd + lokal D1 (tarmoq va hisob kerak emas)
npm run typecheck
```

## Egasi uchun qadamlar (bir marta)

1. **Cloudflare hisob** — bor. D1 baza `labguide-db` yaratilgan (EEUR,
   id `wrangler.toml` da). Workers & Pages → **workers.dev subdomeni**
   yoqilganini tekshiring (URL `https://labguide-api.<subdomen>.workers.dev`).
2. **API token:** dash.cloudflare.com → My Profile → API Tokens → Create
   Token → *Custom token*:
   - Account → **Workers Scripts: Edit** (deploy, cron trigger, `secret put`, workers.dev)
   - Account → **D1: Edit** (`d1 migrations apply --remote`)
   - Account → **Account Settings: Read**
   - Account Resources: *Include → faqat LabGuide hisobi*. TTL ixtiyoriy.

   **User → Memberships: Read / User Details: Read KERAK EMAS**, agar
   `CLOUDFLARE_ACCOUNT_ID` berilgan bo‘lsa (CI uni har doim beradi —
   6-qadam). Wrangler 4.124 kodi bo‘yicha (`wrangler-dist/cli.js`,
   `getOrSelectAccountId` → `getActiveAccountId`): account id
   `wrangler.toml` dagi `account_id` yoki `CLOUDFLARE_ACCOUNT_ID` dan olinsa,
   `/accounts` va `/memberships` so‘ralmaydi; `/memberships` faqat (a) account
   id noma’lum bo‘lganda hisobni avtomatik tanlashda, (b) `wrangler whoami`
   da va (c) boshqa autentifikatsiya xatosidan keyingi diagnostik `whoami`
   chiqishida chaqiriladi. `/user` va `/user/tokens/verify` ham faqat
   `whoami` uchun. Ya’ni bu ikki ruxsatsiz `wrangler deploy`,
   `d1 migrations apply --remote` va `secret put` ishlaydi; ular yo‘q bo‘lsa
   faqat haqiqiy auth xatosida qo‘shimcha “Are you missing the
   User->Memberships->Read permission?” izohi chiqishi mumkin (asl xato
   boshqa ruxsatda bo‘ladi). `CLOUDFLARE_ACCOUNT_ID` siz (lokal) ishlatilsa —
   Memberships: Read kerak bo‘ladi.

   Token barcha Workerlarni tahrirlay oladi — CI faqat `labguide-api` nomini
   deploy qiladi; tokenni boshqa joyda ishlatmang.
3. **Account ID:** Dashboard → Workers & Pages → o‘ng panel “Account ID”.
4. **Resend:** resend.com da hisob → *Domains* → `alideveloper.uz` qo‘shib,
   DNS’ga SPF/DKIM yozuvlarini kiriting va tasdiqlang → *API Keys* → yangi
   kalit (`re_…`). Jo‘natuvchi: `LabGuide <labguide@alideveloper.uz>`
   (`LG_SENDER_EMAIL` berilmasa shu standart). Zaxira: `EMAIL_PROVIDER=brevo`
   va `BREVO_API_KEY` + tasdiqlangan `LG_SENDER_EMAIL` (brevo.com → *Senders* →
   *SMTP & API → API Keys*).
5. **Server secreti:** `openssl rand -hex 32` — natijani parol menejeriga
   saqlang. U email HMAC kaliti: o‘zgartirilsa yoki yo‘qolsa, mavjud hisoblar
   topilmay qoladi (MyCloud’ga ko‘chirishda ham kerak).
6. **GitHub → Settings → Secrets and variables → Actions → Secrets:**
   - `CLOUDFLARE_API_TOKEN`, `CLOUDFLARE_ACCOUNT_ID`
   - `RESEND_API_KEY` **yoki** `BREVO_API_KEY` (biri yetarli); ixtiyoriy
     `LG_SENDER_EMAIL`; **Variables:** `EMAIL_PROVIDER` (`resend` standart | `brevo`).
     Qiymatlar `wrangler secret put` orqali stdin’dan o‘tadi, logga chiqmaydi.
   - `LG_SERVER_SECRET` (5-qadam)
   - ixtiyoriy: `LG_ADMIN_EMAILS` (masalan, egasining emaili — vergul bilan),
     `CLOUDFLARE_D1_DATABASE_ID` (boshqa baza ishlatilsa)
   - ixtiyoriy, Google/Apple bilan kirish (D-56): `GOOGLE_CLIENT_IDS`,
     `APPLE_SIGNIN_TEAM_ID`, `APPLE_SIGNIN_KEY_ID`, `APPLE_SIGNIN_PRIVATE_KEY`,
     `APPLE_SIGNIN_CLIENT_ID`, `APPLE_SIGNIN_SERVICE_ID` — qadamlari:
     `docs/AUTH_SOCIAL_LOGIN.md`
7. **Deploy:** Actions → LabGuide CI → Run workflow → mode **deploy_api**.
   Job: Worker testlari → D1 migratsiyalari → `labguide-api` deploy →
   secretlar (stdin orqali, logga chiqmaydi) → `/v1/health`. Secret yetishmasa
   job xatosiz o‘tkazib yuboriladi va qaysi biri yo‘qligini yozadi.
8. **Ilovani ulash:** Settings → Variables → **`LG_API_URL`** = summary’dagi
   URL. Keyingi `build`/`testflight`/`play_internal` buildlari shu serverga
   ulanadi (`LG_SUPABASE_*` bo‘lsa ham Cloudflare ustun).
9. **Birinchi admin kirishi:** ilovada `LG_ADMIN_EMAILS` dagi email bilan
   kiring → Admin panel → TOTP. Kalit yo‘qolsa:
   `npx wrangler d1 execute labguide-db --remote --command "DELETE FROM totp_factors WHERE user_id = '<id>'"`.
   Qo‘lda admin berish: `INSERT INTO admins (user_id, granted_at, granted_reason) VALUES ('<id>', <ms>, 'manual')`.
10. **Workers AI (hamjamiyat, D-43):** `wrangler.toml` da `[ai] binding = "AI"`
    va `LG_VERIFY_MODEL` (`@cf/meta/llama-4-scout-17b-16e-instruct`),
    `LG_TRANSLATE_MODEL` (`@cf/meta/m2m100-1.2b`), `LG_OWNER_DISPLAY_NAME`
    (`LabGuide`). Dashboard → AI → Workers AI hisobda yoqilganini tekshiring
    (bepul kunlik “neuron” limiti bor; oshsa `503 ai_unavailable`, ilova halol
    xabar beradi). API tokenga **Account → Workers AI: Read** qo‘shing (deploy
    AI binding bilan rad etilsa — `Edit`). Deploydan keyin bir marta haqiqiy
    sinov: test hujjat surati bilan `/v1/community/verify` va bitta tarjima —
    model javob formati (`response` obyekt yoki matn) parser bilan mosligini
    ko‘ring (testlarda AI soxta). Model almashtirish — faqat var.
11. **Maxfiylik siyosati:** server (Cloudflare, EEUR) va email xizmati (Resend)
    nomlarini `docs/store/PRIVACY_POLICY.md` ga yozing; email ochiq holda
    saqlanmasligini qo‘shish mumkin.

## Keyin MyCloud (yoki boshqa server)ga ko‘chirish

D1 — oddiy SQLite, Worker kodi standart `Request/Response` va WebCrypto.

1. Eksport: `npx wrangler d1 export labguide-db --remote --output labguide.sql`
   (sxema + ma’lumot, SQLite dialekti). Faylni shifrlangan holda saqlang.
2. Yangi serverda SQLite (`sqlite3 labguide.db < labguide.sql`) yoki
   PostgreSQL’ga import (vaqtlar — Unix ms `INTEGER`, JSON maydonlar — `TEXT`).
3. Kod: `createApp()` faqat `env.DB` (D1 interfeysi: `prepare/bind/first/all/run/batch`)
   ni ishlatadi — `better-sqlite3` ustida shu interfeysli kichik o‘ram yozib,
   Node.js (yoki workerd) da ishga tushirish mumkin. Cron o‘rniga tizim
   taymeri.
4. Bir xil `LG_SERVER_SECRET` — aks holda email HMAC’lar mos kelmaydi va
   foydalanuvchilar yangi hisob ochib qo‘yadi. Sessiya tokenlari ham ishlayveradi.
5. Ilovada faqat `LG_API_URL` o‘zgaradi (yangi build). O‘zbekiston
   qonunchiligi (shaxsiy ma’lumotlarni mahalliy saqlash) uchun ko‘chirish
   rejasini yurist bilan tekshiring.
