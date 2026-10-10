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
                                   └──▶ Resend API (faqat kirish kodi xati; ixtiyoriy Brevo)
```

| Joy | Nima |
|---|---|
| `cloudflare/src/app.ts` | marshrutlar, umumiy xato ishlovi (ichki tafsilot chiqmaydi), CORS, kunlik tozalash (cron) |
| `cloudflare/src/auth.ts` | email OTP, sessiyalar, profil, admin TOTP, hisobni o‘chirish |
| `cloudflare/src/groups.ts` | guruhlar, a’zolik, mavzular, savol-javob belgilari, test sessiyalari, natijalar |
| `cloudflare/src/crypto.ts` | HMAC, SHA-256, AES-GCM, TOTP (faqat WebCrypto) |
| `cloudflare/src/email.ts` | email yuboruvchi: Resend (standart) / Brevo, uz/ru/en matn |
| `cloudflare/migrations/` | D1 sxemasi: `0001_auth`, `0002_classroom`, `0003_planned_ports` (faqat sxema), `0004_teacher_topics` (ustoz ro‘yxati, mavzu bosqichlari va testi) |
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
| `POST /v1/auth/logout` | sessiya | joriy tokenni bekor qiladi |
| `POST /v1/auth/logout-all` | sessiya | hamma qurilmalardan chiqish |
| `GET /v1/me` | sessiya | `{user_id, role, language, admin_account, aal, admin, reviewer, teacher}` |
| `POST /v1/me/teacher` | sessiya | ustoz sifatida ro‘yxat (`registerTeacher`) |
| `PUT /v1/me/profile` `{role?, language?}` | sessiya | rol: `doctor/lab/student/teacher` (boshqasi — 400) |
| `DELETE /v1/me` | sessiya | hisob va unga bog‘liq hamma narsa o‘chadi |
| `GET /v1/auth/mfa` | admin hisobi | TOTP holati |
| `POST /v1/auth/mfa/enroll` | admin hisobi, faktor hali yo‘q | TOTP kalit va `otpauth://` URI |
| `POST /v1/auth/mfa/verify` `{code}` | admin hisobi | sessiya `aal2` bo‘ladi |

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
| Pro huquqlari | `/v1/entitlements` | `verify-purchase` porti (do‘kon API), ilova faqat o‘qiydi |

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
  keyingi kirishda olinadi) yoki egasi qo‘lda (`granted_reason='manual'`).
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
10. **Maxfiylik siyosati:** server (Cloudflare, EEUR) va email xizmati (Resend)
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
